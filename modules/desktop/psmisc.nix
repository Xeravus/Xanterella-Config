{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.psmisc.enable {
    environment = {
      systemPackages = with pkgs; [
        psmisc
      ];
    };
  };
  options = {
    xanterella = {
      psmisc = {
        enable = lib.mkEnableOption "Aktiviert psmisc";
      };
    };
  };
}