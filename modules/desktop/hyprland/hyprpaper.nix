{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xanterella.hyprpaper;
in {
    config = lib.mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs; [
          hyprpaper
        ];
      };
    };
    options = {
      xanterella = {
        hyprpaper = {
          enable = lib.mkEnableOption "Aktiviert Hyprpaper";
        };
      };
    };
  }