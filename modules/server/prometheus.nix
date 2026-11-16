{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.xanterella.prometheus;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      services = {
        prometheus = {
          exporters = {
            node = {
              enable = true;
              enabledCollectors = [
                "systemd"
                "hwmon"
                "tcpstat"
              ];
              listenAddress = "0.0.0.0";
              port = 9100;
            };
            process = {
              enable = true;
              listenAddress = "0.0.0.0";
              port = 9101;
              settings = {
                process_names = [
                  {
                    cmdline = [
                      ".*netbird.*"
                    ];
                    name = "Netbird";
                  }
                  {
                    cmdline = [
                      ".*tailscaled.*"
                    ];
                    name = "Tailscale";
                  }
                  {
                    cmdline = [
                      ".*caddy.*"
                    ];
                    name = "Caddy";
                  }
                  {
                    cmdline = [
                      ".*grafana.*"
                    ];
                    name = "Grafana";
                  }
                  {
                    cmdline = [
                      ".*podman-immich-postgres.*"
                      ".*podman-immich-server.*"
                      ".*podman-immich-redis.*"
                    ];
                    name = "Immich";
                  }
                  {
                    cmdline = [
                      ".*github-runner.*"
                    ];
                    name = "GitHub-Runner";
                  }
                  {
                    cmdline = [
                      ".*vikunja.*"
                    ];
                    name = "Vikunja";
                  }
                  {
                    cmdline = [
                      ".*vaultwarden.*"
                    ];
                    name = "Vaultwarden";
                  }
                  {
                    cmdline = [
                      ".*audiobookshelf.*"
                    ];
                    name = "Audiobookshelf";
                  }
                  {
                    cmdline = [
                      ".*synapse.*"
                    ];
                    name = "Matrix Synapse";
                  }
                  {
                    cmdline = [
                      ".*mautrix-discord.*"
                    ];
                    name = "Matrix Discord";
                  }
                  {
                    cmdline = [
                      ".*mautrix-whatsapp.*"
                    ];
                    name = "Matrix Whatsapp";
                  }
                  {
                    cmdline = [
                      ".*atticd.*"
                    ];
                    name = "Attic";
                  }
                ];
              };
            };
          };
        };
      };
    };
    options = {
      xanterella = {
        prometheus = {
          enable = lib.mkEnableOption "Aktiviert Prometheus";
        };
      };
    };
  }