{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.xanterella.vaultwarden;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      services = {
        vaultwarden = {
          config = {
            ROCKET_ADDRESS = "0.0.0.0";
            ROCKET_PORT = 8222;
            WEBSOCKET_ENABLED = true;
          };
          enable = true;
          package = pkgs-unstable.vaultwarden;
        };
      };
    };
    options = {
      xanterella = {
        vaultwarden = {
          enable = lib.mkEnableOption "Aktiviert Vaultwarden ohne externes Speichermedium";
        };
      };
    };
  }