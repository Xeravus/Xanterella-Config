{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      arm = {
        enable = true;
      };
      btop = {
        enable = true;
      };
      cluster-node = {
        enable = true;
      };
      fastfetch = {
        enable = true;
      };
      github-runner = {
        "default_builder" = {
          labels = [
            "nixos"
            "fast"
            "self-hosted"
            "xanterella"
          ];
          url = "https://github.com/Xeravus/Xanterella-Cli";
        };
      };
      immich-ml = {
        enable = true;
      };
      jellyfin = {
        enable = true;
      };
      minecraft-server = {
        enable = true;
      };
      prometheus = {
        enable = true;
      };
      stress = {
        enable = true;
      };
    };
  };
}