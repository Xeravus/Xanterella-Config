{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    xanterella = {
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
      direnv = {
        enable = true;
      };
      fastfetch = {
        enable = true;
      };
      spicetify = {
        enable = true;
      };
    };
  };
}