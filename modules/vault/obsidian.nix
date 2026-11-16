{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.obsidian.enable {
    environment = {
      systemPackages = with pkgs; [
        obsidian
      ];
    };
  };
  options = {
    xanterella = {
      obsidian = {
        enable = lib.mkEnableOption "Aktiviert obsidian";
      };
    };
  };
}