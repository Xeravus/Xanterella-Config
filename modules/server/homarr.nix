{
  config,
  pkgs-new,
  lib,
  inputs,
  ...
}: let
  cfg = config.xanterella.homarr;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/homarr 0755 root root -"
            "d /mnt/server-data/homarr/configs 0755 root root -"
            "d /mnt/server-data/homarr/icons 0755 root root -"
            "d /mnt/server-data/homarr/data 0755 root root -"
          ];
        };
      };
      virtualisation = {
        oci-containers = {
          backend = "podman";
          containers = {
            homarr = {
              image = "ghcr.io/ajnart/homarr:latest";
              ports = [
                "0.0.0.0:7575:7575"
              ];
              volumes = [
                "${inputs.xanterella-etc}/homarr:/app/data/configs"
                "/mnt/server-data/homarr/icons:/app/public/icons"
                "/mnt/server-data/homarr/data:/data"
              ];
            };
          };
        };
      };
    };
    options = {
      xanterella = {
        homarr = {
          domain = lib.mkOption {
            default = "${nodeCfg.domain}";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert Homarr. Eine Homepage";
        };
      };
    };
  }