{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.hashcat.enable {
    environment = {
      systemPackages = with pkgs; [
        hashcat
      ];
    };
  };
  options = {
    xanterella = {
      hashcat = {
        enable = lib.mkEnableOption "Aktiviert hashcat";
      };
    };
  };
}