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
  options = {
    xanterella = {
      garage = {
        enable = lib.mkEnableOption "Aktiviert Garage S3 Object Storage Cluster";
      };
    };
  };

  config = lib.mkIf (cfg.enable && nodeCfg.enable) {
    age = {
      secrets = {
        garage-secrets = {
          file = ./../agenix/s3.env.age;
          mode = "0400";
        };
      };
    };

    services = {
      garage = {
        enable = true;
        package = pkgs-unstable.garage;
        environmentFile = config.age.secrets.garage-secrets.path;
        settings = {
          metadata_dir = "/mnt/server-data/garage/meta";
          data_dir = "/mnt/server-data/garage/data";
          db_engine = "sqlite";
          replication_level = 3;
          consistency_mode = "consistent";

          # Cluster-Kommunikation (RPC)
          rpc_bind_addr = "[::]:3901";
          # Jeder Node meldet sich mit seiner eigenen Tailscale-Adresse im Cluster
          rpc_public_addr = "${config.networking.hostName}.${nodeCfg.tailscale-domain}:3901";

          # S3 API
          s3_api = {
            s3_region = "garage";
            api_bind_addr = "[::]:3900";
            root_domain = ".s3.${nodeCfg.domain}";
          };

          # Web Hosting (Optional, z.B. für statische Websites)
          s3_web = {
            bind_addr = "[::]:3902";
            root_domain = ".web.${nodeCfg.domain}";
          };

          # Admin API
          admin = {
            api_bind_addr = "[::]:3903";
          };
        };
      };
    };

    systemd = {
      services = {
        garage-setup = {
          description = "Prepare Directories for Garage Object Storage";
          before = ["garage.service"];
          requiredBy = ["garage.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            # Erstellt die Verzeichnisse als root, bevor Garage startet
            ExecStart = "${pkgs.coreutils}/bin/mkdir -p /mnt/server-data/garage/meta /mnt/server-data/garage/data";
            # Übergibt die Rechte an den Garage-User
            ExecStartPost = "${pkgs.coreutils}/bin/chown -R garage:garage /mnt/server-data/garage";
          };
        };
      };

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
    users.users.garage = {
      isSystemUser = true;
      group = "garage";
      home = "/var/lib/garage";
      createHome = true;
    };
    users.groups.garage = {};

    networking = {
      firewall = {
        interfaces."tailscale0" = {
          allowedTCPPorts = [
            3900 # S3 API
            3901 # RPC Cluster-Traffic
            3902 # Web
            3903 # Admin
          ];
        };
      };
    };
  };
}
