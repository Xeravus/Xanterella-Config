{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ./../../modules
    ./../../profiles/boot/boot-crylia.nix
    ./../../profiles/essentials/essentials-crylia.nix
    ./../../profiles/apps/apps.nix
    ./../../profiles/desktops/gnome.nix
  ];
  networking = {
    hostName = "crylia";
  };
  fileSystems = lib.mkDefault {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
  system = {
    stateVersion = "25.11"; # Did you read the comment?
  };
}
