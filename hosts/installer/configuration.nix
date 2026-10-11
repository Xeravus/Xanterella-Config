{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  secrets = import "/home/cato/xanterella/config/modules/agenix/usb-secrets.nix";
in {
  imports = [
    ./../../modules
    ./../../profiles/desktops/gnome.nix
    ./../../profiles/apps/installer-apps.nix
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  isoImage = {
    squashfsCompression = "zstd";
  };
  networking = {
    hostName = "installer";
  };
  nixpkgs.config.allowUnfree = true;
}
