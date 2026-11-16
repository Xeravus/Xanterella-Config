{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.gdm.enable {
    services = {
      xserver = {
        desktopManager = {
          gnome = {
            enable = true;
          };
        };
        displayManager = {
          gdm = {
            enable = true;
          };
        };
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      gdm = {
        enable = lib.mkEnableOption "Aktiviert gdm";
      };
    };
  };
}