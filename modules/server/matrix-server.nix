{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  pkgs-bleeding,
  ...
}: let
  cfg = config.xanterella.matrix-server;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          matrix-password = {
            file = ./../agenix/matrix.yaml.age;
            group = "matrix-synapse";
            owner = "matrix-synapse";
          };
        };
      };
      networking = {
        firewall = {
          allowedTCPPorts = [
            1007
          ];
        };
      };
      services = {
        caddy = {
          enable = true;
          virtualHosts = {
            "http://matrix.xanterella.de" = {
              extraConfig = ''
              reverse_proxy /_matrix* 127.0.0.1:8008
              reverse_proxy /_synapse/client* 127.0.0.1:8008

              handle /.well-known/matrix/client {
                header Access-Control-Allow-Origin "*"
                header Content-Type "application/json"
                respond `{
                  "m.homeserver": {
                    "base_url": "https://matrix.xanterella.de"
                  }
                }`
              }
            '';
            };
            "http://xanterella.de" = {
              extraConfig = ''
              handle /.well-known/matrix/client {
                header Access-Control-Allow-Origin "*"
                header Content-Type "application/json"
                respond `{
                  "m.homeserver": {
                    "base_url": "https://matrix.xanterella.de"
                  }
                }`
              }
            '';
            };
          };
        };
        matrix-synapse = {
          enable = true;
          extraConfigFiles = [
            config.age.secrets.matrix-password.path
          ];
          settings = {
            database = {
              allow_unsafe_locale = true;
              args = {
                database = "matrix-synapse";
                host = "/run/postgresql";
                user = "matrix-synapse";
              };
              name = "psycopg2";
            };
            enable_registration = false;
            server_name = cfg.domain;
          };
        };
        mautrix-discord = {
          enable = true;
          package = pkgs-bleeding.mautrix-discord;
          settings = {
            appservice = {
              database = {
                type = "postgres";
                uri = "postgres://mautrix-discord@/mautrix-discord?host=/run/postgresql";
              };
            };
            bridge = {
              permissions = {
                "@xeravus:${cfg.domain}" = "admin";
              };
            };
            homeserver = {
              address = "http://127.0.0.1:8008";
              domain = cfg.domain;
            };
          };
        };
        mautrix-whatsapp = {
          enable = true;
          package = pkgs-bleeding.mautrix-whatsapp;
          settings = {
            bridge = {
              permissions = {
                "@xeravus:${cfg.domain}" = "admin";
              };
            };
            homeserver = {
              address = "http://127.0.0.1:8008";
              domain = cfg.domain;
            };
          };
        };
        postgresql = {
          enable = true;
          ensureDatabases = [
            "matrix-synapse"
            "mautrix-whatsapp"
            "mautrix-discord"
          ];
          ensureUsers = [
            {
              ensureDBOwnership = true;
              name = "matrix-synapse";
            }
            {
              ensureDBOwnership = true;
              name = "mautrix-whatsapp";
            }
            {
              ensureDBOwnership = true;
              name = "mautrix-discord";
            }
          ];
        };
        tailscale = {
          enable = true;
          permitCertUid = "caddy";
        };
      };
      systemd = {
        services = {
          matrix-synapse = {
            serviceConfig = {
              TimeoutStartSec = "180s";
            };
          };
        };
      };
      users = {
        users = {
          caddy = {
            extraGroups = [
              "tailscale"
            ];
          };
        };
      };
    };
    options = {
      xanterella = {
        matrix-server = {
          domain = lib.mkOption {
            default = "matrix.${nodeCfg.domain}";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert Matrix Pipeline";
        };
      };
    };
  }