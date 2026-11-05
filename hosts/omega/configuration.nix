{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules
    ./../../profiles/boot/boot.nix
    ./../../profiles/essentials/essentials.nix
    ./../../profiles/vault.nix
    ./../../profiles/apps/omega-apps.nix
    ./../../profiles/desktops/hyprland.nix
  ];

  networking = {
    hostName = "xorus";
  };
  system = {
    stateVersion = "25.11"; # Did you read the comment?
  };
}
