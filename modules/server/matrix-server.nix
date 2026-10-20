{
  config,
  pkgs,
  lib,
  pkgs-unstable,
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
        discord_secrets = {
          file = ./../agenix/mautrix_disord.env.age;
          owner = "mautrix-discord";
          group = "mautrix-discord";
        };
        whatsapp_secrets = {
          file = ./../agenix/mautrix_whatsapp.env.age;
          owner = "mautrix-whatsapp";
          group = "mautrix-whatsapp";
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
          app_service_config_files = [
            "/var/lib/mautrix-whatsapp/whatsapp-registration.yaml"
            "/var/lib/matrix-synapse/discord-registration.yaml"
          ];
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
        package = pkgs-unstable.mautrix-whatsapp;
        environmentFile = config.age.secrets.whatsapp_secrets.path;
        settings = {
          appservice = {
            as_token = "$MAUTRIX_WHATSAPP_APPSERVICE_AS_TOKEN";
            hs_token = "$MAUTRIX_WHATSAPP_APPSERVICE_HS_TOKEN";
          };
          database = {
            type = "postgres";
            uri = "postgres://mautrix-whatsapp@/mautrix-whatsapp?host=/run/postgresql";
          };
          homeserver = {
            address = "http://127.0.0.1:8008";
            domain = cfg.domain;
          };
          bridge = {
            permissions = {
              "@xeravus:${nodeCfg.domain}" = "admin";
            };
          };
        };
      };

      mautrix-discord = {
        enable = true;
        environmentFile = config.age.secrets.discord_secrets.path;
        settings = {
          appservice = {
            as_token = "$MAUTRIX_DISCORD_APPSERVICE_AS_TOKEN";
            hs_token = "$MAUTRIX_DISCORD_APPSERVICE_HS_TOKEN";
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
              "@xeravus:${nodeCfg.domain}" = "admin";
            };
          };
        };
      };
      caddy = {
        enable = true;
        virtualHosts = {
          "matrix.${nodeCfg.domain}" = {
            extraConfig = ''
              reverse_proxy /_matrix* 127.0.0.1:8008
              reverse_proxy /_synapse/client* 127.0.0.1:8008

              header /.well-known/matrix/* Access-Control-Allow-Origin "*"

              respond /.well-known/matrix/server `{"m.server": "matrix.${nodeCfg.domain}:443"}`
              respond /.well-known/matrix/client `{
                "m.homeserver": {
                  "base_url": "https://matrix.${nodeCfg.domain}"
                }
              }`
            '';
          };
        };
      };
      tailscale = {
        enable = true;
        permitCertUid = "caddy";
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

    nixpkgs = {
      config = {
        permittedInsecurePackages = [
          "olm-3.2.16"
        ];
      };
    };
  };
}
