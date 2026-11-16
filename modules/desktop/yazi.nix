{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.yazi.enable {
    environment = {
      systemPackages = with pkgs; [
        yazi
      ];
    };
    programs = {
      yazi = {
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      yazi = {
        enable = lib.mkEnableOption "Aktiviert yazi";
      };
    };
  };
}