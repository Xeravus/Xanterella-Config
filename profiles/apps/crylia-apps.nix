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
      };
      btop = {
        enable = true;
      };
      direnv = {
        enable = true;
      };
      fastfetch = {
        enable = true;
      };
    };
  };
}