{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: let
  cfg = config.xanterella.cluster-node;
in {
  options = {
    xanterella = {
      cluster-node = {
        enable = lib.mkEnableOption "Aktiviert die Vorbereitung für Services";

        domain = lib.mkOption {
          type = lib.types.str;
          default = "xanterella.de";
        };

        tailscale-domain = lib.mkOption {
          type = lib.types.str;
          default = "gute-nessie.ts.net";
        };

        head = lib.mkEnableOption "Macht den Server zum Head Server";

        monitoring-server = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.cluster-node.enable {
      xanterella = {
        arcane-agent = {
          enable = true;
        };
      };
      networking = {
        firewall = {
          trustedInterfaces = ["tailscale0"];
        };
      };
    })
    (lib.mkIf (config.xanterella.cluster-node.enable && config.xanterella.cluster-node.head) {
      age = {
        secrets = {
          cloudflare-token = {
            file = ./../agenix/cloudflare-token.age;
          };
        };
      };
      environment = {
        systemPackages = with pkgs-unstable; [
          vlc
        ];
      };
      systemd = {
        services = {
          cloudflare-tunnel = {
            description = "Cloudflare Zero Trust Tunnel";
            wantedBy = ["multi-user.target"];
            after = ["network-online.target"];
            wants = ["network-online.target"];

            serviceConfig = {
              ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
              EnvironmentFile = config.age.secrets.cloudflare-token.path;

              Restart = "always";
              RestartSec = "5s";
              User = "root";
            };
          };
        };
      };
    })
  ];
}
