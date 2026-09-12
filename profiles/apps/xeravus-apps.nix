{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    xanterella = {
      cluster-node = {
        enable = false;
        domain = "xeravus.gute-nessie.ts.net";
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
      jellyfin-bucket = {
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
