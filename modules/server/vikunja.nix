{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.xanterella.vikunja;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      services = {
        vikunja = {
          enable = true;
          frontendHostname = "${config.networking.hostName}";
          frontendScheme = "https";
          port = 8919;
          settings = {
            service = {
              frontendurl = "https://${nodeCfg.domain}";
            };
          };
        };
      };
    };
    options = {
      xanterella = {
        vikunja = {
          enable = lib.mkEnableOption "Aktiviert Vikuna";
        };
      };
    };
  }