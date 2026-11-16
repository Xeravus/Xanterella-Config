{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.logitech.enable {
    environment = {
      systemPackages = with pkgs; [
        piper
      ];
    };
    services.ratbagd.enable = true;
  };
  options = {
    xanterella = {
      logitech = {
        enable = lib.mkEnableOption "Aktiviert logitech";
      };
    };
  };
}