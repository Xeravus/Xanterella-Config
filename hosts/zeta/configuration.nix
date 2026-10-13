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
    ./../../profiles/apps/zeta-apps.nix
    ./disko-config.nix
  ];
  networking = {
    hostName = "zeta";
  };
  system = {
    stateVersion = "26.05";
  };
}
