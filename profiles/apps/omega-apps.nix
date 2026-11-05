{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    xanterella = {
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
      spicetify = {
        enable = true;
      };
      direnv = {
        enable = true;
      };
    };
  };
}
