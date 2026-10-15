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

IMMICH_URL = os.getenv("IMMICH_URL", "http://localhost:2283/api").rstrip("/")
API_KEY_FILE = os.getenv("IMMICH_API_KEY_FILE")
TARGET_TAG = os.getenv("IMMICH_TARGET_TAG", "#upscale")
UPSCALER_CMD = os.getenv("UPSCALER_CMD", "realesrgan-ncnn-vulkan -i {input} -o {output}")
STATE_FILE = Path(os.getenv("STATE_FILE", "/var/lib/immich-upscale/processed.json"))
TMP_DIR = Path(os.getenv("TMP_DIR", "/tmp/immich_upscale"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("immich-upscaler")

def get_api_key() -> str:
    """Liest den API-Key (bevorzugt aus der Agenix-Datei)."""
    if API_KEY_FILE and Path(API_KEY_FILE).exists():
        with open(API_KEY_FILE, "r") as f:
            return f.read().strip()
    key = os.getenv("IMMICH_API_KEY")
    if not key:
        logger.error("Kein API-Key gefunden! Weder IMMICH_API_KEY_FILE noch IMMICH_API_KEY ist gesetzt.")
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

def get_tag_id(session: requests.Session, tag_name: str) -> str:
    """Holt die interne UUID des Immich-Tags basierend auf seinem Namen."""
    url = f"{IMMICH_URL}/tags"
    resp = session.get(url)
    if resp.status_code != 200:
        logger.warning(f"Konnte Tag-Liste nicht laden: {resp.status_code}")
        return None
        
    tags = resp.json()
    for tag in tags:
        # Entferne ein eventuelles '#' aus dem TARGET_TAG für den Vergleich
        clean_target = tag_name.lstrip('#').lower()
        if tag.get("name", "").lower() == clean_target or tag.get("value", "").lower() == clean_target:
            return tag.get("id")
            
    return None

def get_assets_to_process(session: requests.Session) -> List[Dict[str, Any]]:
    """Holt gezielt die Assets, die mit dem Tag verknüpft sind."""
    logger.info(f"Suche nach Assets mit dem Tag: {TARGET_TAG} ...")
    
    # 1. UUID des Tags herausfinden
    tag_id = get_tag_id(session, TARGET_TAG)
    
    if not tag_id:
        logger.warning(f"Tag '{TARGET_TAG}' in Immich nicht gefunden! Breche Suche ab.")
        return []

    logger.info(f"Tag-UUID gefunden: {tag_id}. Lade verknüpfte Assets...")

    # 2. Nutze den Endpunkt: GET /tags/{id}/assets (Standard-Verhalten in vielen Immich Versionen)
    # Alternativ (je nach exakter Sub-Version) über den Search-Endpunkt, aber mit korrektem Format.
    
    url = f"{IMMICH_URL}/tags/{tag_id}/assets"
    resp = session.get(url)
    
    # Fallback, falls der /tags/{id}/assets Endpunkt in dieser Version nicht existiert
    if resp.status_code == 404:
        logger.debug("Fallback auf /search/metadata mit Tag-Filter...")
        url_search = f"{IMMICH_URL}/search/metadata"
        # In Version 3.x+ wird oft das `tagIds` Array in der Payload ignoriert, wenn man `withExif` nutzt.
        # Wir übergeben es hier in der korrekten Struktur für die moderne Suche.
        payload = {
            "tagIds": [tag_id]
        }
        resp = session.post(url_search, json=payload)
        
    resp.raise_for_status()
    data = resp.json()
    
    # Entpacke die Antwort, je nachdem welcher Endpunkt geantwortet hat
    if isinstance(data, dict):
        tagged_assets = data.get("assets", data.get("items", []))
    else:
        tagged_assets = data

    # 3. Wir müssen sicherstellen, dass wir volle Asset-Objekte haben
    final_assets = []
    for asset in tagged_assets:
        if isinstance(asset, str): # Falls nur IDs kamen
            try:
                detail_resp = session.get(f"{IMMICH_URL}/assets/{asset}")
                if detail_resp.status_code == 200:
                    final_assets.append(detail_resp.json())
            except Exception:
                continue
        elif isinstance(asset, dict):
            final_assets.append(asset)
            
    logger.info(f"{len(final_assets)} Assets mit dem Tag '{TARGET_TAG}' gefunden.")
    return final_assets

def remove_tag(session: requests.Session, asset_id: str, current_description: str):
    """(Optional) Entfernt den Tag nach dem Upscaling aus der Beschreibung, um Ordnung zu halten."""
    if not current_description: return
    new_desc = current_description.replace(TARGET_TAG, "").strip()
    
    url = f"{IMMICH_URL}/assets/{asset_id}"
    resp = session.put(url, json={"description": new_desc})
    if resp.status_code == 200:
        logger.info(f"Tag '{TARGET_TAG}' erfolgreich vom Original-Asset entfernt.")

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
    
    # Originale Metadaten (Zeitstempel) kopieren, damit es in der Timeline am selben Ort bleibt
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
            
            processed_ids.append(asset_id)
            save_state(processed_ids)
            
        except Exception as e:
            logger.error(f"Fehler bei Asset {asset_id}: {e}")
        finally:
            if in_path.exists(): in_path.unlink()
            if out_path.exists(): out_path.unlink()

if __name__ == "__main__":
    main()
