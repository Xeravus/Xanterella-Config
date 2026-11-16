{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.xanterella.utils.enable {
    environment = {
      systemPackages = with pkgs; [
        pciutils
        usbutils
      ];
    };
  };
  options = {
    xanterella = {
      utils = {
        enable = lib.mkEnableOption "Aktiviert Utilities";
      };
    };
  };
}