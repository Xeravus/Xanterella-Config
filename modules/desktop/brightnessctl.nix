{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.brightnessctl.enable {
    environment = {
      systemPackages = with pkgs; [
        brightnessctl
      ];
    };
  };
  options = {
    xanterella = {
      brightnessctl = {
        enable = lib.mkEnableOption "Aktiviert brightnessctl";
      };
    };
  };
}