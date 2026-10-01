{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  inputs,
  ...
}: let
  pomo = pkgs-unstable.buildGoModule {
    pname = "pomo";
    version = "latest";
    src = inputs.pomo-src;
    vendorHash = "sha256-kbTYq4Xc86bcmNMhInq1rwYTbGRmu2TEXT2e7bqT5YY=";
  };
in {
  options = {
    xanterella = {
      pomodoro = {
        enable = lib.mkEnableOption "Aktiviert pomodoro";
      };
    };
  };

  config = lib.mkIf config.xanterella.pomodoro.enable {
    environment = {
      systemPackages = [
        pkgs.pom
        pomo
      ];
    };
  };
}
