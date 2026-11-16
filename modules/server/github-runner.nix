{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.xanterella.github-runner;
in {
    config = lib.mkIf (cfg != { }) {
      age = {
        secrets = {
          github-runner-token = {
            file = ./../agenix/github-runner.age;
          };
        };
      };
      services = {
        github-runners = lib.mapAttrs (runnerName: runnerCfg: {
            enable = true;
            extraLabels = runnerCfg.labels;
            extraPackages = with pkgs-unstable; [
              git
              nodejs
              bash
            ];
            name = "${config.networking.hostName}-${runnerName}";
            nodeRuntimes = [
              "node24"
            ];
            package = pkgs-unstable.github-runner;
            replace = true;
            tokenFile = config.age.secrets.github-runner-token.path;
            url = runnerCfg.url;
          }) cfg;
      };
    };
    options = {
      xanterella = {
        github-runner = lib.mkOption {
          default = { };
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              labels = lib.mkOption {
                default = [ ];
                type = lib.types.listOf lib.types.str;
              };
              url = lib.mkOption {
                type = lib.types.str;
              };
            };
          });
        };
      };
    };
  }