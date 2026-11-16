{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.nitch.enable {
    environment = {
      systemPackages = with pkgs; [
        nitch
      ];
    };
  };
  options = {
    xanterella = {
      nitch = {
        enable = lib.mkEnableOption "Aktiviert nitch";
      };
    };
  };
}