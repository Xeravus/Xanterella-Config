{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.xanterella.audiobookshelf;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/audiobookshelf 0755 root root -"
            "d /mnt/server-data/audiobookshelf/config 0755 root root -"
            "d /mnt/server-data/audiobookshelf/metadata 0755 root root -"
            "d /mnt/server-data/audiobookshelf/audiobooks 0755 root root -"
          ];
        };
      };
      virtualisation = {
        oci-containers = {
          backend = "podman";
          containers = {
            audiobookshelf = {
              image = "ghcr.io/advplyr/audiobookshelf:latest";
              ports = [
                "0.0.0.0:13378:80"
              ];
              volumes = [
                "/mnt/server-data/audiobookshelf/config:/config"
                "/mnt/server-data/audiobookshelf/metadata:/metadata"
                "/mnt/server-data/audiobookshelf/audiobooks:/audiobooks"
              ];
            };
          };
        };
      };
    };
    options = {
      xanterella = {
        audiobookshelf = {
          domain = lib.mkOption {
            default = "${nodeCfg.domain}:1005";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert audiobookshelf";
        };
      };
    };
  }