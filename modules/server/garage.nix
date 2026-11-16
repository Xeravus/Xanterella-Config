{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: let
  cfg = config.xanterella.garage;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          garage-secrets = {
            file = ./../agenix/s3.env.age;
            mode = "0400";
          };
        };
      };
      networking = {
        firewall = {
          interfaces."tailscale0" = {
            allowedTCPPorts = [
              3900
              3901
              3902
              3903
            ];
          };
        };
      };
      services = {
        garage = {
          enable = true;
          environmentFile = config.age.secrets.garage-secrets.path;
          package = pkgs-unstable.garage;
          settings = {
            admin = {
              api_bind_addr = "[::]:3903";
            };
            consistency_mode = "consistent";
            data_dir = "/mnt/server-data/garage/data";
            db_engine = "sqlite";
            metadata_dir = "/mnt/server-data/garage/meta";
            replication_factor = 1;
            rpc_bind_addr = "[::]:3901";
            rpc_public_addr = "${config.networking.hostName}.${nodeCfg.tailscale-domain}:3901";
            s3_api = {
              api_bind_addr = "[::]:3900";
              root_domain = ".s3.${nodeCfg.domain}";
              s3_region = "garage";
            };
            s3_web = {
              bind_addr = "[::]:3902";
              root_domain = ".web.${nodeCfg.domain}";
            };
          };
        };
      };
      systemd = {
        services = {
          garage = {
            unitConfig = {
              RequiresMountsFor = "/mnt/server-data";
            };
          };
        };
        tmpfiles = {
          rules = [
            "d /mnt/server-data/garage 0700 garage garage -"
            "d /mnt/server-data/garage/meta 0700 garage garage -"
            "d /mnt/server-data/garage/data 0700 garage garage -"
          ];
        };
      };
      users.groups.garage = { };
      users.users.garage = {
        createHome = true;
        group = "garage";
        home = "/var/lib/garage";
        isSystemUser = true;
      };
    };
    options = {
      xanterella = {
        garage = {
          enable = lib.mkEnableOption "Aktiviert Garage S3 Object Storage Cluster";
        };
      };
    };
  }