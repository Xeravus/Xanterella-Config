{
  config,
  pkgs-bleeding,
  lib,
  pkgs,
  ...
}: let
  cfg = config.xanterella.attic-server;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      environment = {
        systemPackages = with pkgs-bleeding; [
          openssl
        ];
      };
      services = {
        atticd = {
          enable = true;
          environmentFile = "/root/secrets/atticd.env";
          package = pkgs-bleeding.attic-server;
          settings = {
            chunking = {
              "avg-size" = 65536;
              "max-size" = 262144;
              "min-size" = 16384;
              "nar-size-threshold" = 65536;
            };
            database = {
              url = "postgres:///attic?host=/var/run/postgresql&user=attic";
            };
            listen = "0.0.0.0:6000";
            storage = {
              path = "/mnt/server-data/attic/storage";
              type = "local";
            };
          };
        };
      };
      services.postgresql = {
        enable = true;
        ensureDatabases = [
          "attic"
        ];
        ensureUsers = [
          {
            ensureDBOwnership = true;
            name = "attic";
          }
        ];
        package = pkgs.postgresql_16;
      };
      systemd = {
        services = {
          atticd = {
            serviceConfig = {
              DynamicUser = lib.mkForce false;
              ReadWritePaths = [
                "/mnt/server-data/attic"
              ];
            };
          };
        };
        tmpfiles = {
          rules = [
            "d /mnt/server-data/attic 0750 atticd atticd -"
            "d /mnt/server-data/attic/storage 0750 atticd atticd -"
          ];
        };
      };
      users = {
        groups = {
          atticd = { };
        };
        users = {
          atticd = {
            group = "atticd";
            isSystemUser = true;
          };
        };
      };
    };
    options = {
      xanterella = {
        attic-server = {
          domain = lib.mkOption {
            default = "${nodeCfg.domain}:1001";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert Attic für Caching";
        };
      };
    };
  }