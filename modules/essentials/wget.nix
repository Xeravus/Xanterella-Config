{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.wget.enable {
    environment = {
      systemPackages = with pkgs; [
        wget
      ];
    };
  };
  options = {
    xanterella = {
      wget = {
        enable = lib.mkEnableOption "Aktiviert wget";
      };
    };
  };
}