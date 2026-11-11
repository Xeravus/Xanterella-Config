{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    xanterella = {
      cluster-node = {
        enable = true;
        domain = "xeravus.gute-nessie.ts.net";
      };
      garage = {
        enable = true;
      };
      ani-cli = {
        enable = true;
      };
      browser = {
        zen = {
          enable = true;
        };
        librewolf = {
          enable = true;
        };
      };
      brightnessctl = {
        enable = true;
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
