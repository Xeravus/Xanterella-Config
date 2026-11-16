{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.libnotify.enable {
    environment = {
      systemPackages = with pkgs; [
        libnotify
      ];
    };
  };
  options = {
    xanterella = {
      libnotify = {
        enable = lib.mkEnableOption "Aktiviert libnotify";
      };
    };
  };
}