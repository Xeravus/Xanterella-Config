{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.inkscape.enable {
    environment = {
      systemPackages = with pkgs; [
        inkscape
      ];
    };
  };
  options = {
    xanterella = {
      inkscape = {
        enable = lib.mkEnableOption "Aktiviert inkscape";
      };
    };
  };
}