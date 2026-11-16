{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.gnome-keyring.enable {
    security = {
      pam = {
        services = {
          sddm = {
            enableGnomeKeyring = true;
            enableKwallet = lib.mkForce false;
          };
        };
      };
    };
    services = {
      gnome = {
        gcr-ssh-agent = {
          enable = false;
        };
        gnome-keyring = {
          enable = true;
        };
      };
    };
  };
  options = {
    xanterella = {
      gnome-keyring = {
        enable = lib.mkEnableOption "Aktiviert gnome-keyring";
      };
    };
  };
}