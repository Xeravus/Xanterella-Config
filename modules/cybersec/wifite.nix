{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.wifite.enable {
    environment = {
      systemPackages = with pkgs; [
        wifite2
      ];
    };
  };
  options = {
    xanterella = {
      wifite = {
        enable = lib.mkEnableOption "Aktiviert wifite";
      };
    };
  };
}