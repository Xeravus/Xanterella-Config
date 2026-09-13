{
  pkgs-unstable,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.xanterella.jellyfin;
  nodeCfg = config.xanterella.cluster-node;
  remount = pkgs.writeShellScriptBin "s3remount" ''
    echo "Stoppe rclone-Dienst..."
    sudo systemctl stop rclone-s3-mount.service

    echo "Löse blockierte FUSE-Mounts..."
    # Das -uz erzwingt die Trennung des spezifischen Pfades, auch wenn lokale Prozesse ihn blockieren
    sudo fusermount -uz /mnt/server-data/jellyfin/s3-media 2>/dev/null || true

    echo "Starte rclone-Dienst neu..."
    sudo systemctl start rclone-s3-mount.service

    echo "Neuer Mount-Status:"
    sudo systemctl status rclone-s3-mount.service --no-pager | grep "Active:"
  '';
  s3move = pkgs.writeShellScriptBin "s3move" ''
    if [ -z "$1" ]; then
      echo "Fehler: Bitte gib einen Ordnerpfad an."
      echo "Nutzung: $0 \"/pfad/zum/ordner\""
      exit 1
    fi

    SOURCE_PATH="$1"
    FOLDER_NAME=$(basename "$SOURCE_PATH")
    BUCKET_DEST="garage-s3:jellyfin-bucket/Movies"
    RCLONE_CONF="/run/agenix/rclone-conf"
    sudo rclone move "$SOURCE_PATH" "$BUCKET_DEST/$FOLDER_NAME" \
      --config "$RCLONE_CONF" \
      -P \
      --transfers 1 \
      --s3-disable-checksum \
      --delete-empty-src-dirs
    sleep 3
    rm -r $SOURCE_PATH
  '';
in {
  options = {
    xanterella = {
      jellyfin = {
        enable = lib.mkEnableOption "Aktiviert Jellyfin";
      };
      jellyfin-bucket = {
        enable = lib.mkEnableOption "Aktiviert den Jellyfin-Bucket für rclone";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.jellyfin-bucket.enable {
      age = {
        secrets = {
          rclone-conf = {
            file = ./../agenix/rclone.conf.age;
            owner = "root";
            group = "root";
            mode = "0400";
          };
        };
      };
      environment = {
        systemPackages = with pkgs-unstable; [
          rclone
          s3move
        ];
      };
    })
    (lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          rclone-conf = {
            file = ./../agenix/rclone.conf.age;
            owner = "root";
            group = "root";
            mode = "0400";
          };
        };
      };
      environment = {
        systemPackages = with pkgs-unstable; [
          rclone
          remount
          s3move
        ];
      };
      services = {
        jellyfin = {
          enable = true;
          package = pkgs-unstable.jellyfin;
        };
      };
      programs = {
        fuse = {
          userAllowOther = true;
        };
      };
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/jellyfin 0775 root root -"
            "d /mnt/server-data/jellyfin 0775 root root -"
            "d /mnt/server-data/jellyfin/s3-media 0775 root root -"
          ];
        };
        services = {
          rclone-s3-mount = {
            description = "Rclone Mount für Garage S3 Storage";
            requires = ["network-online.target"];
            after = ["network-online.target"];
            wantedBy = ["multi-user.target"];

            serviceConfig = {
              Type = "notify";
              ExecStart = ''
                ${pkgs.rclone}/bin/rclone mount garage-s3:jellyfin-bucket /mnt/server-data/jellyfin/s3-media \
                  --config=${config.age.secrets.rclone-conf.path} \
                  --allow-other \
                  --vfs-cache-mode full \
                  --vfs-cache-max-size 200G \
                  --vfs-read-chunk-size 32M \
                  --dir-cache-time 72h \
                  --attr-timeout 1h
                  --log-level INFO \
                  --use-server-modtime \
                  --no-checksum \
                  --buffer-size 0M \
                  --syslog
              '';
              ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/server-data/jellyfin/s3-media";
              Restart = "on-failure";
              RestartSec = "10s";
            };
          };
        };
      };
    })
  ];
}
