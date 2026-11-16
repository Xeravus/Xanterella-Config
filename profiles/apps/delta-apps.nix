{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
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
            "self-hosted"
            "xanterella"
          ];
          url = "https://github.com/Xeravus/Xanterella-Cli";
        };
      };
      prometheus = {
        enable = true;
      };
    };
  };
}