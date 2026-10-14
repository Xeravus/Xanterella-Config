{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.xanterella.noctalia;

  noctaliaConfigFile = ./noctalia.toml;
in {
  options = {
    xanterella = {
      noctalia = {
        enable = lib.mkEnableOption "Aktiviert Noctalia deklarativ über tmpfiles";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      sessionVariables = {
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CACHE_HOME = "$HOME/.cache";
      };
      etc = {
        "xanterella-etc" = {
          source = inputs.xanterella-etc;
        };
      };
      systemPackages = [
        inputs.noctalia.packages.${pkgs.system}.default
        pkgs.nix-search-tv
      ];
    };
    systemd = {
      user = {
        services = {
          noctalia = {
            description = "Noctalia App Launcher";
            restartIfChanged = true;
            reloadTriggers = [noctaliaConfigFile];
            environment = {
              PATH = lib.mkForce "/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/cato/bin";
            };

            serviceConfig = {
              ExecStart = "${inputs.noctalia.packages.${pkgs.system}.default}/bin/noctalia";
              Restart = "always";
              RestartSec = "3";
            };
          };
        };
        services = {
          libinput = {
            enable = true;
          };
        };
        tmpfiles = {
          rules = [
            "d %h/.config/noctalia 0755 - - -"
            "L+ %h/.config/noctalia/config.toml - - - - ${noctaliaConfigFile}"
          ];
        };
      };
    };
  };
}
