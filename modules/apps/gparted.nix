{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.gparted.enable {
    environment = {
      systemPackages = with pkgs; [
        gparted
        parted
      ];
    };
  };
  options = {
    xanterella = {
      gparted = {
        enable = lib.mkEnableOption "Aktiviert gparted";
      };
    };
  };
}