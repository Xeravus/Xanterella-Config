{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.aircrack-ng.enable {
    environment = {
      systemPackages = with pkgs; [
        aircrack-ng
      ];
    };
  };
  options = {
    xanterella = {
      aircrack-ng = {
        enable = lib.mkEnableOption "Aktiviert aircrack-ng";
      };
    };
  };
}