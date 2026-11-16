{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.gnome.enable {
    environment = {
      gnome = {
        excludePackages = with pkgs; [
          gnome-tour
          geary
          epiphany
        ];
      };
      systemPackages = with pkgs; [
        gnome-tweaks
        gnome-extension-manager
      ];
    };
    services = {
      gnome = {
        gcr-ssh-agent = {
          enable = false;
        };
      };
      libinput = {
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      gnome = {
        enable = lib.mkEnableOption "Aktiviert gnome";
      };
    };
  };
}