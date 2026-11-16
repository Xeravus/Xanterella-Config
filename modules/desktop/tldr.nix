{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.tldr.enable {
    environment = {
      systemPackages = with pkgs; [
        tldr
      ];
    };
  };
  options = {
    xanterella = {
      tldr = {
        enable = lib.mkEnableOption "Aktiviert tldr";
      };
    };
  };
}