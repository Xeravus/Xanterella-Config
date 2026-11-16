{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.gamemode.enable {
    programs = {
      gamemode = {
        enable = true;
        enableRenice = true;
      };
    };
  };
  options = {
    xanterella = {
      gamemode = {
        enable = lib.mkEnableOption "Aktiviert gamemode";
      };
    };
  };
}