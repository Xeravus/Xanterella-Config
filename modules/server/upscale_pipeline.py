#!/usr/bin/env python3
import os
import sys
import json
import logging
import subprocess
import shlex
from pathlib import Path
from typing import List, Dict, Any

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# --- Konfiguration ---
IMMICH_URL = os.getenv("IMMICH_URL", "http://localhost:2283/api").rstrip("/")
API_KEY_FILE = os.getenv("IMMICH_API_KEY_FILE")
ALBUM_ID = os.getenv("IMMICH_ALBUM_ID") # MUSS gesetzt werden!
UPSCALER_CMD = os.getenv("UPSCALER_CMD", "realesrgan-ncnn-vulkan -i {input} -o {output} -v")
STATE_FILE = Path(os.getenv("STATE_FILE", "/var/lib/immich-upscale/processed.json"))
TMP_DIR = Path(os.getenv("TMP_DIR", "/tmp/immich_upscale"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("immich-upscaler")

def get_api_key() -> str:
    """Liest den API-Key aus der Agenix-Datei oder der Umgebung."""
    if API_KEY_FILE and Path(API_KEY_FILE).exists():
        with open(API_KEY_FILE, "r") as f:
            return f.read().strip()
    key = os.getenv("IMMICH_API_KEY")
    if not key:
        logger.error("Kein API-Key gefunden!")
        sys.exit(1)
    return key

def get_session() -> requests.Session:
    session = requests.Session()
    session.headers.update({"x-api-key": get_api_key(), "Accept": "application/json"})
    retries = Retry(total=5, backoff_factor=1, status_forcelist=[502, 503, 504])
    session.mount("http://", HTTPAdapter(max_retries=retries))
    return session

def load_state() -> List[str]:
    return json.loads(STATE_FILE.read_text()) if STATE_FILE.exists() else []

def save_state(processed_ids: List[str]):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(processed_ids))

def get_assets_to_process(session: requests.Session) -> List[Dict[str, Any]]:
    """Holt alle Assets, die mit dem Herz-Symbol (isFavorite) markiert sind."""
    logger.info("Suche nach Bildern mit Herz-Symbol (Favoriten)...")
    
    url = f"{IMMICH_URL}/search/metadata"
    # Offizieller und stabiler API-Parameter für Favoriten
    payload = {"isFavorite": True}
    
    resp = session.post(url, json=payload)
    resp.raise_for_status()
    data = resp.json()
    
    raw_assets = []
    
    # Entpacken der Suchergebnisse
    if isinstance(data, dict):
        if "assets" in data and isinstance(data["assets"], dict) and "items" in data["assets"]:
            raw_assets = data["assets"]["items"]
        elif "assets" in data and isinstance(data["assets"], list):
            raw_assets = data["assets"]
        elif "items" in data and isinstance(data["items"], list):
            raw_assets = data["items"]
    elif isinstance(data, list):
        raw_assets = data
            
    if not raw_assets:
        logger.warning("Keine Favoriten gefunden. (Hast du die Bilder mit einem Herz markiert?)")
        return []
        
    full_assets = []
    for item in raw_assets:
        asset_id = item.get("id") if isinstance(item, dict) else item
        if not asset_id: 
            continue
        
        try:
            # Lade die vollen Details nach
            detail_resp = session.get(f"{IMMICH_URL}/assets/{asset_id}")
            if detail_resp.status_code == 200:
                full_assets.append(detail_resp.json())
        except Exception as e:
            logger.debug(f"Konnte Details für {asset_id} nicht laden: {e}")
            
    logger.info(f"{len(full_assets)} Favoriten geladen und bereit.")
    return full_assets

def remove_favorite(session: requests.Session, asset_id: str):
    """Entfernt das Herz-Symbol vom verarbeiteten Asset."""
    url = f"{IMMICH_URL}/assets/{asset_id}"
    resp = session.put(url, json={"isFavorite": False})
    
    if resp.status_code == 200:
        logger.info(f"Herz-Symbol erfolgreich vom Original-Asset entfernt.")
    else:
        logger.warning(f"Konnte Herz-Symbol nicht entfernen (Code {resp.status_code}).")

def upload_asset(session: requests.Session, file_path: Path, original_meta: Dict[str, Any]) -> str:
    """Lädt das Bild hoch und garantiert eine einzigartige ID für das Stacking."""
    url = f"{IMMICH_URL}/assets"
    
    # NEU: Wir nutzen die einzigartige 'id' des Originalbildes, damit Immich
    # niemals denkt, es handele sich um Duplikate.
    unique_id = original_meta.get('id', 'fallback')
    
    data = {
        'deviceAssetId': f"upscale_{unique_id}",
        'deviceId': 'nixos-ai-pipeline',
        'fileCreatedAt': original_meta.get('fileCreatedAt'),
        'fileModifiedAt': original_meta.get('fileModifiedAt')
    }
    
    with open(file_path, "rb") as f:
        resp = session.post(url, data=data, files={'assetData': (file_path.name, f, 'image/jpeg')})
        resp.raise_for_status()
        
    return resp.json().get("id")

def remove_from_album(session: requests.Session, asset_id: str):
    """Entfernt das verarbeitete Asset aus dem Upscale-Album, um aufzuräumen."""
    url = f"{IMMICH_URL}/albums/{ALBUM_ID}/assets"
    # Die Immich API nutzt DELETE mit einem Body (assetIds) für das Entfernen
    resp = session.delete(url, json={"assetIds": [asset_id]})
    
    if resp.status_code in [200, 201, 204]:
        logger.info(f"Original-Asset erfolgreich aus dem Upscale-Album entfernt.")
    else:
        logger.warning(f"Konnte Asset nicht aus dem Album entfernen (Code {resp.status_code}).")

def download_asset(session: requests.Session, asset: Dict[str, Any], out_path: Path):
    asset_id = asset["id"]
    url = f"{IMMICH_URL}/assets/{asset_id}/original"
    resp = session.get(url, stream=True)
    if resp.status_code != 200:
        resp = session.get(f"{IMMICH_URL}/asset/file/{asset_id}?isThumb=false", stream=True)
    resp.raise_for_status()
    
    with open(out_path, "wb") as f:
        for chunk in resp.iter_content(chunk_size=8192):
            f.write(chunk)
    logger.info(f"Download abgeschlossen: {asset_id}")

def upscale_image(input_path: Path, output_path: Path):
    cmd = UPSCALER_CMD.format(input=str(input_path), output=str(output_path))
    logger.info(f"Führe Upscaling aus: {cmd}")
    
    process = subprocess.run(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    if process.returncode != 0:
        logger.error(f"Upscaler Fehler:\n{process.stdout}")
        raise RuntimeError("Upscaling fehlgeschlagen")
    logger.info("Upscaling erfolgreich.")

def upload_asset(session: requests.Session, file_path: Path, original_meta: Dict[str, Any]) -> str:
    url = f"{IMMICH_URL}/assets"
    data = {
        'deviceAssetId': f"upscaled_{original_meta.get('deviceAssetId', 'unknown')}",
        'deviceId': 'nixos-ai-pipeline',
        'fileCreatedAt': original_meta.get('fileCreatedAt'),
        'fileModifiedAt': original_meta.get('fileModifiedAt')
    }
    
    with open(file_path, "rb") as f:
        resp = session.post(url, data=data, files={'assetData': (file_path.name, f, 'image/jpeg')})
        resp.raise_for_status()
        
    return resp.json().get("id")

def stack_assets(session: requests.Session, parent_id: str, child_id: str):
    url = f"{IMMICH_URL}/stacks/{parent_id}"
    resp = session.put(url, json={"assetIds": [child_id]})
    if resp.status_code >= 400:
        resp = session.put(f"{IMMICH_URL}/assets/{child_id}", json={"stackParentId": parent_id})
        resp.raise_for_status()
    logger.info(f"Gestackt: {parent_id} -> {child_id}")

def main():
    TMP_DIR.mkdir(parents=True, exist_ok=True)
    session = get_session()
    processed_ids = load_state()
    assets = get_assets_to_process(session)

    for asset in assets:
        asset_id = asset["id"]
        # Falls das Bild schon verarbeitet wurde oder kein Bild ist, überspringen
        if asset_id in processed_ids or asset.get("type", "IMAGE") != "IMAGE":
            continue

        original_ext = Path(asset.get("originalFileName", "image.jpg")).suffix
        in_path = TMP_DIR / f"in_{asset_id}{original_ext}"
        out_path = TMP_DIR / f"out_{asset_id}.jpg"

        try:
            download_asset(session, asset, in_path)
            upscale_image(in_path, out_path)
            new_id = upload_asset(session, out_path, asset)
            stack_assets(session, parent_id=new_id, child_id=asset_id)
            
            # Neu: Herz-Symbol wieder wegnehmen!
            remove_favorite(session, asset_id)
            
            processed_ids.append(asset_id)
            save_state(processed_ids)
            
        except Exception as e:
            logger.error(f"Fehler bei Asset {asset_id}: {e}")
        finally:
            if in_path.exists(): in_path.unlink()
            if out_path.exists(): out_path.unlink()

if __name__ == "__main__":
    main()
