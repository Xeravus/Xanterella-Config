{
  config,
  pkgs,
  lib,
  ...
}: let
  pixie-sddm-theme = pkgs.stdenv.mkDerivation {
    installPhase = ''
      mkdir -p $out/share/sddm/themes/pixie
      cp -r ./* $out/share/sddm/themes/pixie/
      echo "QtVersion=6" >> $out/share/sddm/themes/pixie/metadata.desktop
    '';
    pname = "pixie-sddm";
    src = pkgs.fetchFromGitHub {
      owner = "xCaptaiN09";
      repo = "pixie-sddm";
      rev = "main";
      sha256 = "sha256-1PDWX8bJfc0HYMW9MsxWwDXDoYy5aaehUWr7FW3yR9U=";
    };
    version = "1.0";
  };
in {
    config = lib.mkIf config.xanterella.sddm.enable {
      environment = {
        systemPackages = with pkgs; [
          pixie-sddm-theme
          kdePackages.qtdeclarative
          kdePackages.qtsvg
          kdePackages.qt5compat
        ];
      };
      security = {
        pam = {
          services = {
            sddm = {
              enableKwallet = true;
            };
          };
        };
      };
      services = {
        displayManager = {
          defaultSession = "hyprland";
          sddm = {
            autoNumlock = true;
            enable = true;
            package = pkgs.kdePackages.sddm;
            theme = "pixie";
            wayland = {
              enable = true;
            };
          };
        };
      };
    };
    options = {
      xanterella = {
        sddm = {
          enable = lib.mkEnableOption "Aktiviert sddm";
        };
      };
    };
  }