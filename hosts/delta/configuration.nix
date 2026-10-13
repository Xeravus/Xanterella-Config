{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./../../modules
    ./../../profiles/boot/boot-server.nix
    ./../../profiles/server/headless.nix
    ./../../profiles/apps/delta-apps.nix
    ./disko-config.nix
  ];
  networking = {
    hostName = "delta";
  };
  system = {
    stateVersion = "26.05";
  };
}
