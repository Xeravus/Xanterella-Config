{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.pulsemixer.enable {
    environment = {
      systemPackages = with pkgs; [
        pulsemixer
      ];
    };
  };
  options = {
    xanterella = {
      pulsemixer = {
        enable = lib.mkEnableOption "Aktiviert pulsemixer";
      };
    };
  };
}