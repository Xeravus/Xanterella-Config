{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    #./hardware-configuration.nix
    ./disko.nix
    ./../../modules
    ./../../profiles/boot/boot-server.nix
    ./../../profiles/server/headless.nix
    ./../../profiles/apps/zeta-apps.nix
  ];
  networking = {
    hostName = "zeta";
  };
  system = {
    stateVersion = "26.05";
  };
}
