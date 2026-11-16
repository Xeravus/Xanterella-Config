{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      gnome-keyring = {
        enable = true;
      };
      hyprland = {
        enable = true;
      };
      hyprpicker = {
        enable = true;
      };
      nix-timetracker = {
        enable = true;
      };
      noctalia = {
        enable = true;
      };
      screenshots = {
        enable = true;
      };
      sddm = {
        enable = true;
      };
    };
  };
  imports = [
    ./desktop.nix
  ];
}