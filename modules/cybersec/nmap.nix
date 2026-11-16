{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.nmap.enable {
    environment = {
      systemPackages = with pkgs; [
        nmap
      ];
    };
  };
  options = {
    xanterella = {
      nmap = {
        enable = lib.mkEnableOption "Aktiviert nmap";
      };
    };
  };
}