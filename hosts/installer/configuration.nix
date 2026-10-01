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
    ./../../profiles/installer.nix
    ./../../profiles/desktops/gnome.nix
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  isoImage = {
    squashfsCompression = "zstd";
  };
  networking = {
    hostName = "cyros";
  };
  nixpkgs.config.allowUnfree = true;
}
