{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    xanterella = {
      discord = {
        enable = lib.mkEnableOption "Aktiviert discord";
      };
    };
  };

  config = lib.mkIf config.xanterella.discord.enable {
    environment = {
      systemPackages = with pkgs; [
        discord
      ];
    };
  };
}
