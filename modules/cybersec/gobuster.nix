{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.gobuster.enable {
    environment = {
      systemPackages = with pkgs; [
        gobuster
      ];
    };
  };
  options = {
    xanterella = {
      gobuster = {
        enable = lib.mkEnableOption "Aktiviert gobuster";
      };
    };
  };
}