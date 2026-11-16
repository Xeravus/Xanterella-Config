{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.proxychains.enable {
    environment = {
      systemPackages = with pkgs; [
        proxychains
      ];
    };
  };
  options = {
    xanterella = {
      proxychains = {
        enable = lib.mkEnableOption "Aktiviert proxychains";
      };
    };
  };
}