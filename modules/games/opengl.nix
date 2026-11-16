{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.opengl.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
  options = {
    xanterella = {
      opengl = {
        enable = lib.mkEnableOption "Aktiviert opengl";
      };
    };
  };
}