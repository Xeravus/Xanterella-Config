{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  config = lib.mkIf config.xanterella.proton.enable {
    environment = {
      systemPackages = with pkgs-unstable; [
        protonup-ng
      ];
    };
  };
  options = {
    xanterella = {
      proton = {
        enable = lib.mkEnableOption "Aktiviert proton";
      };
    };
  };
}