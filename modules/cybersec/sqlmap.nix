{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.sqlmap.enable {
    environment = {
      systemPackages = with pkgs; [
        sqlmap
      ];
    };
  };
  options = {
    xanterella = {
      sqlmap = {
        enable = lib.mkEnableOption "Aktiviert sqlmap";
      };
    };
  };
}