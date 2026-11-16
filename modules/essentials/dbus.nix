{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.dbus.enable {
    environment = {
      systemPackages = with pkgs; [
        dbus
      ];
    };
    services = {
      dbus = {
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      dbus = {
        enable = lib.mkEnableOption "Aktiviert dbus";
      };
    };
  };
}