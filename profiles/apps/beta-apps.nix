{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      cluster-node = {
        enable = true;
      };
      github-runner = {
        "default_builder" = {
          url = "https://github.com/Xeravus/Xanterella-Cli";
          labels = [
            "nixos"
            "fast"
            "self-hosted"
            "xanterella"
          ];
        };
      };
      jellyfin = {
        enable = true;
      };
      arm = {
        enable = true;
      };
      fastfetch = {
        enable = true;
      };
      btop = {
        enable = true;
      };
      prometheus = {
        enable = true;
      };
      stress = {
        enable = true;
      };
      immich-ml = {
        enable = true;
      };
    };
  };
}
