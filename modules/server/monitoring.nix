{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  cfg = config.xanterella.monitoring;
  nodeCfg = config.xanterella.cluster-node;
  ClusterNodes = ["alpha" "beta" "gamma" "delta" "epsilon" "zeta"];

  rawNodeDashboard = builtins.fromJSON (builtins.readFile "${inputs.xanterella-etc}/grafana/monitoring.json");
  patchedNodeDashboard =
    rawNodeDashboard
    // {
      title = "Node Exporter";
      uid = "custom-node-dashboard-01";
    };
  rawProcessDashboard = builtins.fromJSON (builtins.readFile "${inputs.xanterella-etc}/grafana/process.json");
  patchedProcessDashboard =
    rawProcessDashboard
    // {
      title = "Process Exporter";
      uid = "custom-process-dashboard-01";
    };

  customDashboardDir = pkgs.runCommand "custom-dashboards" {} ''
    mkdir -p $out
    cp ${pkgs.writeText "node.json" (builtins.toJSON patchedNodeDashboard)} $out/node.json
    cp ${pkgs.writeText "process.json" (builtins.toJSON patchedProcessDashboard)} $out/process.json
  '';
in {
  options = {
    xanterella = {
      monitoring = {
        enable = lib.mkEnableOption "Aktiviert Monitoring";
        domain = lib.mkOption {
          type = lib.types.str;
          default = "${nodeCfg.domain}:99";
        };
      };
    };
  };
  config = lib.mkIf config.xanterella.monitoring.enable {
    services = {
      prometheus = {
        enable = true;
        port = 9090;
        listenAddress = "0.0.0.0";
        retentionTime = "15d";
        scrapeConfigs = [
          {
            job_name = "node";
            scrape_interval = "10s";
            scheme = "http";
            static_configs =
              builtins.map (host: {
                targets = [
                  "${host}.${nodeCfg.tailscale-domain}:9100"
                ];
                labels = {
                  nodename = host;
                };
              })
              ClusterNodes;
          }
          {
            job_name = "process";
            scrape_interval = "10s";
            scheme = "http";
            static_configs =
              builtins.map (host: {
                targets = [
                  "${host}.${nodeCfg.tailscale-domain}:9101"
                ];
                labels = {
                  nodename = host;
                };
              })
              ClusterNodes;
          }
        ];
      };
      grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "0.0.0.0";
            http_port = 9000;
            domain = cfg.domain;
          };
        };
        provision = {
          enable = true;
          datasources = {
            settings = {
              datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  access = "proxy";
                  url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                  isDefault = true;
                }
              ];
            };
          };
          dashboards = {
            settings = {
              providers = [
                {
                  name = "GitHub Dashboard";
                  options = {
                    path = "${customDashboardDir}";
                  };
                }
              ];
            };
          };
        };
      };
    };
    systemd = {
      services = {
        grafana = {
          environment = {
            GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH = "${inputs.xanterella-etc}/grafana/monitoring.json";
          };
        };
      };
    };
  };
}
