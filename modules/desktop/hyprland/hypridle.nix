{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.hypridle.enable {
    environment = {
      systemPackages = with pkgs; [
        hypridle
      ];
    };
    services = {
      hypridle = {
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      hypridle = {
        enable = lib.mkEnableOption "Aktiviert hypridle";
      };
    };
  };
}