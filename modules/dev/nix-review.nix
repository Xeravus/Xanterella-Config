{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.nix-review.enable {
    environment = {
      systemPackages = with pkgs; [
        nixpkgs-review
      ];
    };
  };
  options = {
    xanterella = {
      nix-review = {
        enable = lib.mkEnableOption "Aktiviert nix-review";
      };
    };
  };
}