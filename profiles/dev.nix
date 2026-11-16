{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      direnv = {
        enable = true;
      };
      github-runner = {
        "fast_builder" = {
          labels = [
            "nixos"
            "self-hosted"
            "xanterella"
            "fast"
          ];
          url = "https://github.com/Xeravus/Xanterella-Cli";
        };
      };
      lazysql = {
        enable = true;
      };
      nix-review = {
        enable = true;
      };
      nodejs = {
        enable = true;
      };
      tokei = {
        enable = true;
      };
      vimgolf = {
        enable = true;
      };
      vscode = {
        enable = true;
      };
    };
  };
}