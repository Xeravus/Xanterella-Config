{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.btop.enable {
    environment = {
      systemPackages = with pkgs; [
        btop
      ];
    };
  };
  options = {
    xanterella = {
      btop = {
        enable = lib.mkEnableOption "Aktiviert btop";
      };
    };
  };
}