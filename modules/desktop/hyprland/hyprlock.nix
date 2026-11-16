{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.hyprlock.enable {
    environment = {
      systemPackages = with pkgs; [
        hyprlock
      ];
    };
    programs = {
      hyprlock = {
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      hyprlock = {
        enable = lib.mkEnableOption "Aktiviert hyprlock";
      };
    };
  };
}