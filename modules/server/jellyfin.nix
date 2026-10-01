{
  pkgs-unstable,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.xanterella.jellyfin;
  nodeCfg = config.xanterella.cluster-node;
  armUid = "1100";
  armGid = "5000";
  armMediaDir = "/mnt/server-data/arm";
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
  playlists = {
    "Frankfurt Tinder - Zarbex" = "https://www.youtube.com/results?search_query=frankfurt+tinder+zarbex+playlist";
  };
  localTmpPath = "/tmp/yt-staging";
  basePath = "/mnt/server-data/jellyfin/s3-media/YTSerien";
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
      '')
      playlists)}

    echo "Synchronisation abgeschlossen."
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
      arm = {
        enable = lib.mkEnableOption "Aktiviert den ARM Stack";
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
      users = {
        groups = {
          media = {
            gid = 5000;
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
          yt-cookie = {
            file = ./../agenix/yt-cookie.txt.age;
          };
        };
      };
      users = {
        groups = {
          media = {
            gid = 5000;
          };
        };
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
      services = {
        jellyfin = {
          enable = true;
          package = pkgs-unstable.jellyfin;
        };
        sonarr = {
          enable = true;
          group = "media";
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
            "d /mnt/server-data/jellyfin/s3-media 0775 root root -"
          ];
        };
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
          yt-playlist-sync = {
            description = "Synchronisiert YouTube Playlists in den S3-Mount";
            after = ["rclone-s3-mount.service"];
            requires = ["rclone-s3-mount.service"];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${syncScript}/bin/yt-playlist-sync";
              User = "root";
            };
          };
          rclone-s3-mount = {
            description = "Rclone Mount für Garage S3 Storage";
            requires = ["network-online.target"];
            after = ["network-online.target"];
            wantedBy = ["multi-user.target"];

            serviceConfig = {
              Type = "notify";
              ExecStartPre = "-${pkgs.fuse}/bin/fusermount -uz /mnt/server-data/jellyfin/s3-media";
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
              ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/server-data/jellyfin/s3-media";
              Restart = "on-failure";
              RestartSec = "10s";
            };
          };
        };
        timers = {
          yt-playlist-sync = {
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "*-*-* 03:00:00";
              Persistent = true;
            };
          };
        };
      };
    })
    (lib.mkIf config.xanterella.arm.enable {
      xanterella = {
        vlc = {
          enable = true;
        };
      };
      virtualisation = {
        podman = {
          enable = true;
          defaultNetwork = {
            settings = {
              dns_enabled = true;
              nameservers = ["100.100.100.100"];
            };
          };
        };
        oci-containers = {
          containers = {
            arm = {
              image = "automaticrippingmachine/automatic-ripping-machine:latest";
              ports = ["0.0.0.0:8987:8080"];
              volumes = [
                "${armMediaDir}/etc:/etc/arm/config"
                "${armMediaDir}/home:/home/arm"
              ];
              environment = {
                ARM_UID = armUid;
                ARM_GID = armGid;
              };
              extraOptions = [
                "--device=/dev/sr0:/dev/sr0"
                "--privileged"
              ];
            };
          };
        };
      };
      boot = {
        kernelModules = ["sg"];
      };
      systemd = {
        tmpfiles = {
          rules = [
            "d ${armMediaDir} 0775 ${armUid} ${armGid} -"
            "d ${armMediaDir}/etc 0775 ${armUid} ${armGid} -"
            "d ${armMediaDir}/home 0775 ${armUid} ${armGid} -"
            "Z ${armMediaDir} 0775 ${armUid} ${armGid} -"
          ];
        };
        services = {
          "podman-arm" = {
            preStart = ''
              ${pkgs.coreutils}/bin/chown -R ${armUid}:${armGid} ${armMediaDir}
              ${pkgs.coreutils}/bin/chmod -R 775 ${armMediaDir}
            '';
          };
        };
      };
      users = {
        users = {
          cato = {
            extraGroups = ["cdrom" "video" "media"];
          };
        };
      };
      networking.firewall.allowedTCPPorts = [8080];
    })
  ];
}
