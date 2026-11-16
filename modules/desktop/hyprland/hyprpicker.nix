{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.hyprpicker.enable {
    environment = {
      systemPackages = with pkgs; [
        hyprpicker
      ];
    };
  };
  options = {
    xanterella = {
      hyprpicker = {
        enable = lib.mkEnableOption "Aktiviert xyy";
      };
    };
  };
}