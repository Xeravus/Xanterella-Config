{
  config,
  pkgs-unstable,
  lib,
  inputs,
  ...
}: let
  cfg = config.xanterella.ha;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/homeassistant 0755 root root -"
          ];
        };
      };
      virtualisation = {
        oci-containers = {
          backend = "podman";
          containers = {
            homeassistant = {
              autoStart = true;
              environment = {
                TZ = "Europe/Berlin";
              };
              extraOptions = [
                "--network=host"
              ];
              image = "ghcr.io/home-assistant/home-assistant:stable";
              volumes = [
                "/mnt/server-data/homeassistant:/config"
                "/etc/localtime:/etc/localtime:ro"
              ];
            };
          };
        };
        podman = {
          enable = true;
        };
      };
    };
    options = {
      xanterella = {
        ha = {
          enable = lib.mkEnableOption "Aktiviert Home Assisant";
        };
      };
    };
  }