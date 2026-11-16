{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.cava.enable {
    environment = {
      systemPackages = with pkgs; [
        cava
      ];
    };
  };
  options = {
    xanterella = {
      cava = {
        enable = lib.mkEnableOption "Aktiviert cava";
      };
    };
  };
}