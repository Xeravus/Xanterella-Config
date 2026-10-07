{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    xanterella = {
      browser = {
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
      btop = {
        enable = true;
      };
      direnv = {
        enable = true;
      };
    };
  };
}
