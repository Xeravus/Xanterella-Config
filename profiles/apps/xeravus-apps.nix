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
      immich-ml = {
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
