{
  config,
  pkgs-unstable,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.reddit.enable {
    environment = {
      systemPackages = with pkgs-unstable; [
        reddit-tui
      ];
    };
  };
  options = {
    xanterella = {
      reddit = {
        enable = lib.mkEnableOption "Aktiviert reddit";
      };
    };
  };
}