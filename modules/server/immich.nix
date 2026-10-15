{
  config,
  pkgs-new,
  pkgs-unstable,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xanterella.immich;
  cfg-ml = config.xanterella.immich-ml;
  nodeCfg = config.xanterella.cluster-node;
  upscaleScript = pkgs.writeScriptBin "immich-upscaler" ''
    #!${pkgs.python3.withPackages (ps: [ps.requests])}/bin/python3
    ${builtins.readFile ./upscale_pipeline.py}
  '';
in {
  options = {
    xanterella = {
      immich = {
        enable = lib.mkEnableOption "Aktiviert Immich";
        ml-domain = lib.mkOption {
          type = lib.types.str;
          default = "${nodeCfg.domain}";
        };
      };
      immich-ml = {
        enable = lib.mkEnableOption "Aktiviert Immich ML";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          immich-env = {
            file = ./../agenix/immich.env.age;
          };
        };
      };
      virtualisation = {
        podman = {
          enable = true;
          defaultNetwork = {
            settings = {
              dns_enabled = true;
              nameservers = ["100.100.100.100" "1.1.1.1"];
            };
          };
        };
        oci-containers = {
          backend = "podman";
          containers = {
            immich-redis = {
              image = "docker.io/redis:6.2-alpine";
            };
            immich-postgres = {
              image = "docker.io/pgvector/pgvector:pg14";
              environment = {
                POSTGRES_USER = "postgres";
                POSTGRES_DB = "immich";
              };
              environmentFiles = [config.age.secrets.immich-env.path];
              volumes = ["/mnt/server-data/immich/db:/var/lib/postgresql/data"];
            };
            immich-server = {
              image = "ghcr.io/immich-app/immich-server:v3.3.3";
              dependsOn = ["immich-postgres" "immich-redis"];
              ports = [
                "0.0.0.0:2283:2283"
              ];
              volumes = ["/mnt/server-data/immich/upload:/usr/src/app/upload"];
              environment = {
                DB_HOSTNAME = "immich-postgres";
                DB_USERNAME = "postgres";
                DB_DATABASE_NAME = "immich";
                REDIS_HOSTNAME = "immich-redis";
                TZ = "Europe/Berlin";
                IMMICH_MACHINE_LEARNING_ENABLED = "true";
                IMMICH_MACHINE_LEARNING_URL = "http://${cfg.ml-domain}:3003";
              };
              environmentFiles = [
                config.age.secrets.immich-env.path
              ];
            };
          };
        };
      };
      networking = {
        firewall = {
          trustedInterfaces = ["podman0" "tailscale0"];
        };
      };
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/immich 0755 root root -"
            "d /mnt/server-data/immich/db 0755 root root -"
            "d /mnt/server-data/immich/upload 0755 root root -"
            "d /mnt/server-data/immich/model-cache 0755 root root -"
          ];
        };
      };
    })
    (lib.mkIf (cfg-ml.enable && nodeCfg.enable) {
      age = {
        secrets = {
          immich-env = {
            file = ./../agenix/immich.env.age;
          };
          immich-api-key = {
            file = ./../agenix/immich-api-key.age;
            owner = "immich-upscaler";
            group = "immich-upscaler";
            mode = "0400";
          };
        };
      };
      environment = {
        systemPackages = with pkgs-unstable; [
          realesrgan-ncnn-vulkan
        ];
      };
      virtualisation = {
        podman = {
          enable = true;
          defaultNetwork = {
            settings = {
              dns_enabled = true;
            };
          };
        };
        oci-containers = {
          backend = "podman";
          containers = {
            immich-machine-learning = {
              image = "ghcr.io/immich-app/immich-machine-learning:v3.1.0";
              volumes = ["/mnt/server-data/immich/model-cache:/cache"];
              ports = ["0.0.0.0:3003:3003"];
            };
          };
        };
      };
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/immich 0755 root root -"
            "d /mnt/server-data/immich/model-cache 0755 root root -"
          ];
        };
      };
      networking = {
        firewall = {
          trustedInterfaces = ["tailscale0"];
        };
      };
      networking.firewall.allowedTCPPorts = [3003];

      users = {
        users = {
          immich-upscaler = {
            isSystemUser = true;
            group = "immich-upscaler";
            description = "Service user for Immich AI Upscaling Pipeline";
          };
        };
        groups = {
          immich-upscaler = {};
        };
      };

      systemd = {
        services = {
          immich-upscale = {
            description = "Immich AI Upscaling Pipeline";
            after = ["network-online.target"];
            wants = ["network-online.target"];

            environment = {
              IMMICH_URL = "https://immich.xanterella.de/api";
              # Das Skript liest den Key aus dieser Datei (von Agenix bereitgestellt)
              IMMICH_API_KEY_FILE = config.age.secrets.immich-api-key.path;
              # Der Tag, nach dem in der Beschreibung gesucht wird
              IMMICH_TARGET_TAG = "#upscale";

              UPSCALER_CMD = "${pkgs-unstable.realesrgan-ncnn-vulkan}/bin/realesrgan-ncnn-vulkan -i {input} -o {output} -n realesrgan-x4plus";
              TMP_DIR = "/tmp/immich_upscale";
              STATE_FILE = "/var/lib/immich-upscale/processed.json";
            };

            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${upscaleScript}/bin/immich-upscaler";
              User = "immich-upscaler";
              Group = "immich-upscaler";

              StateDirectory = "immich-upscale";
              PrivateTmp = true;
              ProtectSystem = "strict";
              ProtectHome = true;
              NoNewPrivileges = true;
            };
          };
        };

        timers = {
          immich-upscale = {
            description = "Run Immich Upscaling Pipeline";
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "hourly";
              Persistent = true;
            };
          };
        };
      };
    })
  ];
}
