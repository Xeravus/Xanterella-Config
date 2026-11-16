{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.nix-timetracker.enable {
    environment = {
      systemPackages = [
        inputs.nix-programs.packages.${pkgs.system}.timetracker
      ];
    };
  };
  options = {
    xanterella = {
      nix-timetracker = {
        enable = lib.mkEnableOption "Aktiviert nix-timetracker für Hyprland";
      };
    };
  };
}