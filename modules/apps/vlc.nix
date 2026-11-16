{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.vlc.enable {
    environment = {
      systemPackages = with pkgs; [
        vlc
      ];
    };
  };
  options = {
    xanterella = {
      vlc = {
        enable = lib.mkEnableOption "Aktiviert vlc";
      };
    };
  };
}