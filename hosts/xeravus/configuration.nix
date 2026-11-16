{
  config,
  pkgs,
  lib,
  ...
}: {
  boot = {
    binfmt = {
      emulatedSystems = [
        "aarch64-linux"
      ];
    };
  };
  imports = [
    ./hardware-configuration.nix
    ./../../modules
    ./../../profiles/boot/boot.nix
    ./../../profiles/essentials/essentials.nix
    ./../../profiles/apps/xeravus-apps.nix
    ./../../profiles/desktops/hyprland.nix
    ./../../profiles/dev.nix
    ./../../profiles/vault.nix
    ./../../profiles/cybersec.nix
    ./../../profiles/creative.nix
    ./../../profiles/gaming.nix
  ];
  networking = {
    hostName = "xeravus";
  };
  system = {
    stateVersion = "25.11";
  };
  zramSwap.enable = true;
}