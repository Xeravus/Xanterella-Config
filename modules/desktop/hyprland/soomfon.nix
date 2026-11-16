{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.soomfon.enable {
    services = {
      udev = {
        extraRules = ''
          SUBSYSTEM=="usb", ATTR{idVendor}=="5376", ATTR{idProduct}=="12289", MODE="0666", GROUP="plugdev"
          SUBSYSTEM=="usb", ATTR{idVendor}=="1500", ATTR{idProduct}=="3001", MODE="0666", GROUP="plugdev"
        '';
      };
    };
  };
  options = {
    xanterella = {
      soomfon = {
        enable = lib.mkEnableOption "Aktiviert soomfon";
      };
    };
  };
}