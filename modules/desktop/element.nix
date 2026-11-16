{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.element.enable {
    environment = {
      systemPackages = with pkgs; [
        element-desktop
      ];
    };
  };
  options = {
    xanterella = {
      element = {
        enable = lib.mkEnableOption "Aktiviert Element(Matrix Messanger";
      };
    };
  };
}