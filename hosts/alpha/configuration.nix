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
    ./../../profiles/apps/alpha-apps.nix
  ];
  networking = {
    hostName = "alpha";
  };
  system = {
    stateVersion = "26.05";
  };
}
