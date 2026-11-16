{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.tree.enable {
    environment = {
      systemPackages = with pkgs; [
        tree
      ];
    };
  };
  options = {
    xanterella = {
      tree = {
        enable = lib.mkEnableOption "Aktiviert tree";
      };
    };
  };
}