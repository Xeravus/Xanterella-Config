{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.geistmono.enable {
    fonts.packages = [
      pkgs.nerd-fonts.geist-mono
    ];
  };
  options = {
    xanterella = {
      geistmono = {
        enable = lib.mkEnableOption "Aktiviert geistmono";
      };
    };
  };
}