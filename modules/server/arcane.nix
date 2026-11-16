{
  config,
  lib,
  ...
}: let
  cfg = config.xanterella.arcane-agent;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          arcane-token = {
            file = ./. + "/../agenix/arcane-token-${config.networking.hostName}.env.age";
          };
        };
      };
      networking.firewall.allowedTCPPorts = [
        3552
      ];
      virtualisation = {
        oci-containers = {
          containers = {
            arcane-agent = {
              environment = {
                "AGENT_MODE" = "true";
                "EDGE_TRANSPORT" = "poll";
                "MANAGER_API_URL" = "http://lacrux.gute-nessie.ts.net:3552";
              };
              environmentFiles = [
                config.age.secrets.arcane-token.path
              ];
              extraOptions = [
                "--privileged"
                "--network=host"
              ];
              image = "ghcr.io/getarcaneapp/manager:v2";
              volumes = [
                "/run/podman/podman.sock:/var/run/docker.sock"
              ];
            };
          };
        };
        podman = {
          dockerCompat = true;
          dockerSocket = {
            enable = true;
          };
        };
      };
    };
    options = {
      xanterella = {
        arcane-agent = {
          enable = lib.mkEnableOption "Aktiviert Arcane Agent";
        };
      };
    };
  }