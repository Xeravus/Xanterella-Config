{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules
    ./../../profiles/boot/boot-server.nix
    ./../../profiles/server/headless.nix
    ./../../profiles/apps/delta-apps.nix
    disko.nixosModules.disko
    ./disko-config.nix
  ];
  networking = {
    hostName = "delta";
  };
  system = {
    stateVersion = "26.05";
  };
}
