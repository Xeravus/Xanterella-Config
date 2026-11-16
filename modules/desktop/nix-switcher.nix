{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.nix-switcher.enable {
    environment = {
      systemPackages = [
        inputs.nix-programs.packages.${pkgs.system}.switcher
        pkgs.lutgen
      ];
    };
  };
  options = {
    xanterella = {
      nix-switcher = {
        enable = lib.mkEnableOption "Aktiviert nix-switcher für Hyprland";
      };
    };
  };
}