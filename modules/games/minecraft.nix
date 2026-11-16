{
  config,
  pkgs-unstable,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.minecraft.enable {
    environment = {
      systemPackages = with pkgs-unstable; [
        prismlauncher
      ];
    };
  };
  options = {
    xanterella = {
      minecraft = {
        enable = lib.mkEnableOption "Aktiviert minecraft";
      };
    };
  };
}