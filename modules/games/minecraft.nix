{
  config,
  pkgs-unstable,
  lib,
  ...
}: {
  options = {
    xanterella = {
      minecraft = {
        enable = lib.mkEnableOption "Aktiviert minecraft";
      };
    };
  };

  config = lib.mkIf config.xanterella.minecraft.enable {
    environment = {
      systemPackages = with pkgs-unstable; [
        prismlauncher
      ];
    };
  };
}
