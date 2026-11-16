{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xanterella.opsbot;
  nodeCfg = config.xanterella.cluster-node;
  opsbot-script = pkgs.writers.writePython3Bin "opsbot" {
      flakeIgnore = [
        "E501"
        "E302"
        "E305"
        "F401"
        "E265"
        "W293"
      ];
      libraries = [
        pkgs.python3Packages.matrix-nio
      ];
    } (builtins.readFile ./opsbot.py);
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          matrix-opsbot-token = {
            file = ./../agenix/matrix-opsbot-token.age;
            owner = "opsbot";
          };
        };
      };
      security = {
        sudo = {
          extraRules = [
            {
              commands = [
                {
                  command = "/run/current-system/sw/bin/systemctl start podman-metasploitable.service";
                  options = [
                    "NOPASSWD"
                  ];
                }
                {
                  command = "/run/current-system/sw/bin/systemctl stop podman-metasploitable.service";
                  options = [
                    "NOPASSWD"
                  ];
                }
              ];
              users = [
                "opsbot"
              ];
            }
          ];
        };
      };
      systemd = {
        services = {
          opsbot = {
            after = [
              "network-online.target"
            ];
            description = "Matrix ChatOps Bot";
            serviceConfig = {
              ExecStart = "${opsbot-script}/bin/opsbot";
              Group = "opsbot";
              Restart = "always";
              RestartSec = "10s";
              User = "opsbot";
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
      users = {
        groups = {
          opsbot = { };
        };
        users = {
          opsbot = {
            group = "opsbot";
            isSystemUser = true;
          };
        };
      };
    };
    options = {
      xanterella = {
        opsbot = {
          domain = lib.mkOption {
            default = "${nodeCfg.domain}";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert OpsBot ein Matrix Bot";
        };
      };
    };
  }