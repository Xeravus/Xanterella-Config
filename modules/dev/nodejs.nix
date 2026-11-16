{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.nodejs.enable {
    environment = {
      systemPackages = with pkgs; [
        nodejs
      ];
    };
  };
  options = {
    xanterella = {
      nodejs = {
        enable = lib.mkEnableOption "Aktiviert nodejs";
      };
    };
  };
}