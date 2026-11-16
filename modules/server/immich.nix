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
in {
    config = lib.mkMerge [
      (lib.mkIf (cfg.enable && nodeCfg.enable) {
        age = {
          secrets = {
            immich-env = {
              file = ./../agenix/immich.env.age;
            };
          };
        };
        networking = {
          firewall = {
            allowedTCPPorts = [
              2283
            ];
            trustedInterfaces = [
              "podman0"
              "tailscale0"
            ];
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
        virtualisation = {
          oci-containers = {
            backend = "podman";
            containers = {
              immich-postgres = {
                environment = {
                  POSTGRES_DB = "immich";
                  POSTGRES_USER = "postgres";
                };
                environmentFiles = [
                  config.age.secrets.immich-env.path
                ];
                image = "docker.io/pgvector/pgvector:pg14";
                volumes = [
                  "/mnt/server-data/immich/db:/var/lib/postgresql/data"
                ];
              };
              immich-redis = {
                image = "docker.io/redis:6.2-alpine";
              };
              immich-server = {
                dependsOn = [
                  "immich-postgres"
                  "immich-redis"
                ];
                environment = {
                  DB_DATABASE_NAME = "immich";
                  DB_HOSTNAME = "immich-postgres";
                  DB_USERNAME = "postgres";
                  IMMICH_MACHINE_LEARNING_ENABLED = "true";
                  IMMICH_MACHINE_LEARNING_URL = "http://${cfg.ml-domain}:3003";
                  REDIS_HOSTNAME = "immich-redis";
                  TZ = "Europe/Berlin";
                };
                environmentFiles = [
                  config.age.secrets.immich-env.path
                ];
                image = "ghcr.io/immich-app/immich-server:v3.3.3";
                ports = [
                  "0.0.0.0:2283:2283"
                ];
                volumes = [
                  "/mnt/server-data/immich/upload:/usr/src/app/upload"
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
                  "1.1.1.1"
                ];
              };
            };
            enable = true;
          };
        };
      })
      (lib.mkIf (cfg-ml.enable && nodeCfg.enable) {
        age = {
          secrets = {
            immich-env = {
              file = ./../agenix/immich.env.age;
            };
          };
        };
        environment = {
          systemPackages = with pkgs-unstable; [
            realesrgan-ncnn-vulkan
          ];
        };
        hardware = {
          graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
              intel-media-driver
              vulkan-loader
              vulkan-validation-layers
            ];
          };
        };
        networking = {
          firewall = {
            trustedInterfaces = [
              "tailscale0"
            ];
          };
        };
        networking.firewall.allowedTCPPorts = [
          3003
        ];
        systemd = {
          tmpfiles = {
            rules = [
              "d /mnt/server-data/immich 0755 root root -"
              "d /mnt/server-data/immich/model-cache 0755 root root -"
            ];
          };
        };
        virtualisation = {
          oci-containers = {
            backend = "podman";
            containers = {
              immich-machine-learning = {
                image = "ghcr.io/immich-app/immich-machine-learning:v3.1.0";
                ports = [
                  "0.0.0.0:3003:3003"
                ];
                volumes = [
                  "/mnt/server-data/immich/model-cache:/cache"
                ];
              };
            };
          };
          podman = {
            defaultNetwork = {
              settings = {
                dns_enabled = true;
              };
            };
            enable = true;
          };
        };
      })
    ];
    options = {
      xanterella = {
        immich = {
          enable = lib.mkEnableOption "Aktiviert Immich";
          ml-domain = lib.mkOption {
            default = "${nodeCfg.domain}";
            type = lib.types.str;
          };
        };
        immich-ml = {
          enable = lib.mkEnableOption "Aktiviert Immich ML";
        };
      };
    };
  }