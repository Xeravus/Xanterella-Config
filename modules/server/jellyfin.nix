{
  pkgs-unstable,
  pkgs-bleeding,
  config,
  lib,
  pkgs,
  ...
}: let
  armGid = "5000";
  armMediaDir = "/mnt/server-data/arm";
  armUid = "1100";
  basePath = "/mnt/server-data/jellyfin/s3-media/YTSerien";
  cfg = config.xanterella.jellyfin;
  localTmpPath = "/tmp/yt-staging";
  nodeCfg = config.xanterella.cluster-node;
  playlists = {
    "Frankfurt Tinder - Zarbex" = "https://www.youtube.com/results?search_query=frankfurt+tinder+zarbex+playlist";
  };
  remount = pkgs.writeShellScriptBin "s3remount" ''
    echo "Stoppe rclone-Dienst..."
    sudo systemctl stop rclone-s3-mount.service

    echo "Löse blockierte FUSE-Mounts..."
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
    BUCKET_DEST="garage-s3:jellyfin/Movies"
    RCLONE_CONF="/run/agenix/rclone-conf"
    sudo rclone move "$SOURCE_PATH" "$BUCKET_DEST/$FOLDER_NAME" \
      --config "$RCLONE_CONF" \
      -P \
      --transfers 1 \
      --delete-empty-src-dirs
    sleep 3
    rm -r "$SOURCE_PATH"
  '';
  syncScript = pkgs.writeShellScriptBin "yt-playlist-sync" ''
    mkdir -p "${localTmpPath}"

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: url: ''
        echo "Synchronisiere Playlist: ${name}"
        mkdir -p "${basePath}/${name} (2026)/Season 01"

        ${pkgs-unstable.yt-dlp}/bin/yt-dlp \
        --cookies ${config.age.secrets.yt-cookie.path} \
        --download-archive "${basePath}/${name} (2026)/archive.txt" \
        --format "bestvideo+bestaudio/best" \
        --merge-output-format mkv \
        --write-thumbnail \
        --output "${localTmpPath}/${name} - S01E%(playlist_index)02d - %(title)s.%(ext)s" \
        "${url}"

        echo "Verschiebe fertige Dateien nach S3..."
        mv ${localTmpPath}/*.* "${basePath}/${name} (2026)/Season 01/" 2>/dev/null || true
      '') playlists)}

    echo "Synchronisation abgeschlossen."
  '';
in {
    config = lib.mkMerge [
      (lib.mkIf config.xanterella.jellyfin-bucket.enable {
        age = {
          secrets = {
            rclone-conf = {
              file = ./../agenix/rclone.conf.age;
              group = "root";
              mode = "0400";
              owner = "root";
            };
          };
        };
        environment = {
          systemPackages = with pkgs-unstable; [
            rclone
            s3move
          ];
        };
        users = {
          groups = {
            media = {
              gid = 5000;
            };
          };
        };
      })
      (lib.mkIf (cfg.enable && nodeCfg.enable) {
        age = {
          secrets = {
            rclone-conf = {
              file = ./../agenix/rclone.conf.age;
              group = "root";
              mode = "0400";
              owner = "root";
            };
            yt-cookie = {
              file = ./../agenix/yt-cookie.txt.age;
            };
          };
        };
        environment = {
          systemPackages = [
            syncScript
            pkgs-unstable.yt-dlp
            pkgs-unstable.ffmpeg
            pkgs-unstable.rclone
            remount
            s3move
          ];
        };
        hardware = {
          graphics = {
            enable = true;
            extraPackages = with pkgs; [
              libva-vdpau-driver
              libvdpau-va-gl
            ];
          };
        };
        programs = {
          fuse = {
            userAllowOther = true;
          };
        };
        services = {
          jellyfin = {
            enable = true;
            package = pkgs-bleeding.jellyfin;
          };
          radarr = {
            enable = true;
            group = "media";
            settings = {
              server = {
                port = 8988;
              };
            };
          };
          sonarr = {
            enable = true;
            group = "media";
          };
        };
        systemd = {
          services = {
            jellyfin = {
              environment = {
                LIBVA_DRIVER_NAME = "radeonsi";
                XDG_CACHE_HOME = "/var/cache/jellyfin";
              };
              serviceConfig = {
                SupplementaryGroups = [
                  "render"
                  "video"
                ];
              };
            };
            rclone-s3-mount = {
              after = [
                "network-online.target"
              ];
              description = "Rclone Mount für Garage S3 Storage";
              requires = [
                "network-online.target"
              ];
              serviceConfig = {
                ExecStart = ''
                ${pkgs.rclone}/bin/rclone mount garage-s3:jellyfin /mnt/server-data/jellyfin/s3-media \
                  --config=/run/agenix/rclone-conf \
                  --allow-other \
                  --vfs-cache-mode full \
                  --vfs-cache-max-size 200G \
                  --vfs-read-chunk-size 32M \
                  --dir-cache-time 72h \
                  --attr-timeout 1h \
                  --log-level INFO \
                  --use-server-modtime \
                  --no-checksum \
                  --buffer-size 0M \
                  --syslog \
                  --dir-perms=0775 \
                  --file-perms=0664
              '';
                ExecStartPre = "-${pkgs.fuse}/bin/fusermount -uz /mnt/server-data/jellyfin/s3-media";
                ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/server-data/jellyfin/s3-media";
                Restart = "on-failure";
                RestartSec = "10s";
                Type = "notify";
              };
              wantedBy = [
                "multi-user.target"
              ];
            };
            yt-playlist-sync = {
              after = [
                "rclone-s3-mount.service"
              ];
              description = "Synchronisiert YouTube Playlists in den S3-Mount";
              requires = [
                "rclone-s3-mount.service"
              ];
              serviceConfig = {
                ExecStart = "${syncScript}/bin/yt-playlist-sync";
                Type = "oneshot";
                User = "root";
              };
            };
          };
          timers = {
            yt-playlist-sync = {
              timerConfig = {
                OnCalendar = "*-*-* 03:00:00";
                Persistent = true;
              };
              wantedBy = [
                "timers.target"
              ];
            };
          };
          tmpfiles = {
            rules = [
              "d /mnt/server-data/jellyfin 0775 root root -"
              "d /mnt/server-data/jellyfin/s3-media 0775 root root -"
            ];
          };
        };
        users = {
          groups = {
            media = {
              gid = 5000;
            };
          };
        };
      })
      (lib.mkIf config.xanterella.arm.enable {
        boot = {
          kernelModules = [
            "sg"
          ];
        };
        networking.firewall.allowedTCPPorts = [
          8080
        ];
        systemd = {
          services = {
            "podman-arm" = {
              preStart = ''
              ${pkgs.coreutils}/bin/chown -R ${armUid}:${armGid} ${armMediaDir}
              ${pkgs.coreutils}/bin/chmod -R 775 ${armMediaDir}
            '';
            };
          };
          tmpfiles = {
            rules = [
              "d ${armMediaDir} 0775 ${armUid} ${armGid} -"
              "d ${armMediaDir}/etc 0775 ${armUid} ${armGid} -"
              "d ${armMediaDir}/home 0775 ${armUid} ${armGid} -"
              "Z ${armMediaDir} 0775 ${armUid} ${armGid} -"
            ];
          };
        };
        virtualisation = {
          oci-containers = {
            containers = {
              arm = {
                environment = {
                  ARM_GID = armGid;
                  ARM_UID = armUid;
                };
                extraOptions = [
                  "--device=/dev/sr0:/dev/sr0"
                  "--privileged"
                ];
                image = "automaticrippingmachine/automatic-ripping-machine:latest";
                ports = [
                  "0.0.0.0:8987:8080"
                ];
                volumes = [
                  "${armMediaDir}/etc:/etc/arm/config"
                  "${armMediaDir}/home:/home/arm"
                ];
              };
            };
          };
          podman = {
            defaultNetwork = {
              settings = {
                dns_enabled = true;
                nameservers = [
                  "100.100.100.100"
                ];
              };
            };
            enable = true;
          };
        };
        xanterella = {
          vlc = {
            enable = true;
          };
        };
      })
    ];
    options = {
      xanterella = {
        arm = {
          enable = lib.mkEnableOption "Aktiviert den ARM Stack";
        };
        jellyfin = {
          enable = lib.mkEnableOption "Aktiviert Jellyfin";
        };
        jellyfin-bucket = {
          enable = lib.mkEnableOption "Aktiviert den Jellyfin-Bucket für rclone";
        };
      };
    };
  }