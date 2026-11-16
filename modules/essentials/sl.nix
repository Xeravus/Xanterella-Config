{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.sl.enable {
    environment = {
      systemPackages = with pkgs; [
        sl
      ];
    };
  };
  options = {
    xanterella = {
      sl = {
        enable = lib.mkEnableOption "Aktiviert sl";
      };
    };
  };
}