{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: let
  cfg = config.xanterella.cluster-node;
in {
    config = lib.mkMerge [
      (lib.mkIf config.xanterella.cluster-node.enable {
        networking = {
          firewall = {
            trustedInterfaces = [
              "tailscale0"
            ];
          };
        };
        xanterella = {
          arcane-agent = {
            enable = false;
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
              after = [
                "network-online.target"
              ];
              description = "Cloudflare Zero Trust Tunnel";
              serviceConfig = {
                EnvironmentFile = config.age.secrets.cloudflare-token.path;
                ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
                Restart = "always";
                RestartSec = "5s";
                User = "root";
              };
              wantedBy = [
                "multi-user.target"
              ];
              wants = [
                "network-online.target"
              ];
            };
          };
        };
      })
    ];
    options = {
      xanterella = {
        cluster-node = {
          domain = lib.mkOption {
            default = "xanterella.de";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert die Vorbereitung für Services";
          head = lib.mkEnableOption "Macht den Server zum Head Server";
          monitoring-server = lib.mkOption {
            default = "";
            type = lib.types.str;
          };
          tailscale-domain = lib.mkOption {
            default = "gute-nessie.ts.net";
            type = lib.types.str;
          };
        };
      };
    };
  }