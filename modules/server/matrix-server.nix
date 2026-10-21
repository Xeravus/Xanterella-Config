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
  options = {
    xanterella = {
      matrix-server = {
        enable = lib.mkEnableOption "Aktiviert Matrix Pipeline";
        domain = lib.mkOption {
          type = lib.types.str;
          default = "matrix.${nodeCfg.domain}";
        };
      };
    };
  };
  config = lib.mkIf (cfg.enable && nodeCfg.enable) {
    age = {
      secrets = {
        matrix-password = {
          file = ./../agenix/matrix.yaml.age;
          owner = "matrix-synapse";
          group = "matrix-synapse";
        };
      };
    };
    services = {
      postgresql = {
        enable = true;
        ensureDatabases = [
          "matrix-synapse"
          "mautrix-whatsapp"
          "mautrix-discord"
        ];
        ensureUsers = [
          {
            name = "matrix-synapse";
            ensureDBOwnership = true;
          }
          {
            name = "mautrix-whatsapp";
            ensureDBOwnership = true;
          }
          {
            name = "mautrix-discord";
            ensureDBOwnership = true;
          }
        ];
      };
      matrix-synapse = {
        enable = true;
        settings = {
          server_name = cfg.domain;
          enable_registration = false;
          database = {
            name = "psycopg2";
            allow_unsafe_locale = true;
            args = {
              user = "matrix-synapse";
              database = "matrix-synapse";
              host = "/run/postgresql";
            };
          };
        };
        extraConfigFiles = [
          config.age.secrets.matrix-password.path
        ];
      };
      mautrix-whatsapp = {
        enable = true;
        package = pkgs-bleeding.mautrix-whatsapp;
        settings = {
          homeserver = {
            address = "http://127.0.0.1:8008";
            domain = cfg.domain;
          };
          bridge = {
            permissions = {
              "@xeravus:${cfg.domain}" = "admin";
            };
          };
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
          homeserver = {
            address = "http://127.0.0.1:8008";
            domain = cfg.domain;
          };
          bridge = {
            permissions = {
              "@xeravus:${cfg.domain}" = "admin";
            };
          };
        };
      };
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
    networking = {
      firewall = {
        allowedTCPPorts = [
          1007
        ];
      };
    };
  };
}
