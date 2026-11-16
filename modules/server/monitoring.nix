{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  ClusterNodes = [
    "alpha"
    "beta"
    "gamma"
    "delta"
    "epsilon"
    "zeta"
  ];
  cfg = config.xanterella.monitoring;
  customDashboardDir = pkgs.runCommand "custom-dashboards" { } ''
    mkdir -p $out
    cp ${pkgs.writeText "node.json" (builtins.toJSON patchedNodeDashboard)} $out/node.json
    cp ${pkgs.writeText "process.json" (builtins.toJSON patchedProcessDashboard)} $out/process.json
  '';
  nodeCfg = config.xanterella.cluster-node;
  patchedNodeDashboard = rawNodeDashboard // {
    title = "Node Exporter";
    uid = "custom-node-dashboard-01";
  };
  patchedProcessDashboard = rawProcessDashboard // {
    title = "Process Exporter";
    uid = "custom-process-dashboard-01";
  };
  rawNodeDashboard = builtins.fromJSON (builtins.readFile "${inputs.xanterella-etc}/grafana/monitoring.json");
  rawProcessDashboard = builtins.fromJSON (builtins.readFile "${inputs.xanterella-etc}/grafana/process.json");
in {
    config = lib.mkIf config.xanterella.monitoring.enable {
      services = {
        grafana = {
          enable = true;
          provision = {
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
            datasources = {
              settings = {
                datasources = [
                  {
                    access = "proxy";
                    isDefault = true;
                    name = "Prometheus";
                    type = "prometheus";
                    url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                  }
                ];
              };
            };
            enable = true;
          };
          settings = {
            server = {
              domain = cfg.domain;
              http_addr = "0.0.0.0";
              http_port = 9000;
            };
          };
        };
        prometheus = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = 9090;
          retentionTime = "15d";
          scrapeConfigs = [
            {
              job_name = "node";
              scheme = "http";
              scrape_interval = "10s";
              static_configs = builtins.map (host: {
                  labels = {
                    nodename = host;
                  };
                  targets = [
                    "${host}.${nodeCfg.tailscale-domain}:9100"
                  ];
                }) ClusterNodes;
            }
            {
              job_name = "process";
              scheme = "http";
              scrape_interval = "10s";
              static_configs = builtins.map (host: {
                  labels = {
                    nodename = host;
                  };
                  targets = [
                    "${host}.${nodeCfg.tailscale-domain}:9101"
                  ];
                }) ClusterNodes;
            }
          ];
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
    options = {
      xanterella = {
        monitoring = {
          domain = lib.mkOption {
            default = "${nodeCfg.domain}:99";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert Monitoring";
        };
      };
    };
  }