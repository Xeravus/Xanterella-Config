{
  config,
  pkgs,
  lib,
  ...
}: let
  hyprlandConf = ./hyprland.conf;
in {
    config = lib.mkIf config.xanterella.hyprland.enable {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        PASSWORD_STORE = "basic";
        XDG_SESSION_TYPE = "wayland";
      };
      programs = {
        hyprland = {
          enable = true;
          xwayland.enable = true;
        };
      };
      systemd.user.tmpfiles.rules = [
        "d %h/.config/hypr 0755 - - -"
        "L+ %h/.config/hypr/hyprland.conf - - - - ${hyprlandConf}"
        "f %h/.config/hypr/noctalia.conf 0644 - - -"
      ];
      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };
    options = {
      xanterella.hyprland.enable = lib.mkEnableOption "Aktiviert hyprland";
    };
  }