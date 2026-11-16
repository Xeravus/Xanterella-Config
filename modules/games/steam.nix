{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  config = lib.mkIf config.xanterella.steam.enable {
    environment = {
      sessionVariables = {
        STEAM_EXTRA_COMPACT_TOOLS_PATH = "/home/cato/.steam/root/compatibilitytools.d";
      };
    };
    programs = {
      steam = {
        enable = true;
        extraCompatPackages = with pkgs-unstable; [
          proton-ge-bin
        ];
        gamescopeSession = {
          enable = true;
        };
      };
    };
  };
  options = {
    xanterella = {
      steam = {
        enable = lib.mkEnableOption "Aktiviert steam";
      };
    };
  };
}