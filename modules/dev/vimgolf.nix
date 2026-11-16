{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.vimgolf.enable {
    environment = {
      systemPackages = with pkgs; [
        vimgolf
      ];
    };
  };
  options = {
    xanterella = {
      vimgolf = {
        enable = lib.mkEnableOption "Aktiviert vimgolf";
      };
    };
  };
}