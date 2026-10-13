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
    ./../../profiles/apps/epsilon-apps.nix
    disko.nixosModules.disko
    ./disko-config.nix
  ];
  networking = {
    hostName = "epsilon";
  };
  system = {
    stateVersion = "26.05";
  };
}
