{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.xanterella.metasploitable;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      networking = {
        interfaces = {
          lo = {
            ipv4 = {
              addresses = [
                {
                  address = "10.99.99.1";
                  prefixLength = 32;
                }
              ];
            };
          };
        };
      };
      virtualisation = {
        oci-containers = {
          backend = "podman";
          containers = {
            metasploitable = {
              autoStart = false;
              image = "tleemcjr/metasploitable2:latest";
              ports = [
                "10.99.99.1:21:21"
                "10.99.99.1:22:22"
                "10.99.99.1:80:80"
              ];
            };
          };
        };
      };
    };
    options = {
      xanterella = {
        metasploitable = {
          enable = lib.mkEnableOption "Aktiviert Metasploitable 2";
        };
      };
    };
  }