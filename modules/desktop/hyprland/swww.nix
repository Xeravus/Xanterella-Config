{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xanterella.swww;
in {
    config = lib.mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs; [
          swww
        ];
      };
    };
    options = {
      xanterella = {
        swww = {
          enable = lib.mkEnableOption "Aktiviert Swww";
        };
      };
    };
  }