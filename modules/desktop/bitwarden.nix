{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.bitwarden.enable {
    environment = {
      systemPackages = with pkgs; [
        bitwarden-desktop
      ];
    };
    nixpkgs = {
      config = {
        permittedInsecurePackages = [
          "electron-39.8.10"
        ];
      };
    };
  };
  options = {
    xanterella = {
      bitwarden = {
        enable = lib.mkEnableOption "Aktiviert bitwarden";
      };
    };
  };
}