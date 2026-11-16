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
    config = lib.mkIf cfg.enable {
      environment = {
        etc = {
          "xanterella-etc" = {
            source = inputs.xanterella-etc;
          };
        };
        sessionVariables = {
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
        };
        systemPackages = [
          inputs.noctalia.packages.${pkgs.system}.default
          pkgs.nix-search-tv
          pkgs.fzf
        ];
      };
      systemd = {
        user = {
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
    options = {
      xanterella = {
        noctalia = {
          enable = lib.mkEnableOption "Aktiviert Noctalia deklarativ über tmpfiles";
        };
      };
    };
  }