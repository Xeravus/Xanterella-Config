{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    xanterella = {
      ani-cli = {
        enable = true;
      };
      brightnessctl = {
        enable = true;
      };
      browser = {
        librewolf = {
          enable = true;
        };
        zen = {
          enable = true;
        };
      };
      cluster-node = {
        domain = "xeravus.gute-nessie.ts.net";
        enable = false;
      };
      fastfetch = {
        enable = true;
      };
      nitch = {
        enable = true;
      };
      pomodoro = {
        enable = true;
      };
      reddit = {
        enable = true;
      };
      spicetify = {
        enable = true;
      };
    };
  };
}