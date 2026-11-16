{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.nix.enable {
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      optimise = {
        automatic = true;
      };
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "cato"
        ];
      };
    };
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };
  };
  options = {
    xanterella = {
      nix = {
        enable = lib.mkEnableOption "Aktiviert nix";
      };
    };
  };
}