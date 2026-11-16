{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.ffuf.enable {
    environment = {
      systemPackages = with pkgs; [
        ffuf
      ];
    };
  };
  options = {
    xanterella = {
      ffuf = {
        enable = lib.mkEnableOption "Aktiviert ffuf";
      };
    };
  };
}