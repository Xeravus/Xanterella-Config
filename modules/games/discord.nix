{
  config,
  pkgs-unstable,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.discord.enable {
    environment = {
      systemPackages = with pkgs-unstable; [
        discord
      ];
    };
  };
  options = {
    xanterella = {
      discord = {
        enable = lib.mkEnableOption "Aktiviert discord";
      };
    };
  };
}