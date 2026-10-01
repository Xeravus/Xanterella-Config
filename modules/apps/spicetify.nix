{
  config,
  pkgs,
  lib,
  inputs,
  pkgs-unstable,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  spotify-fix = pkgs.symlinkJoin {
    name = "spotify-fix";
    pname = "spotify";
    version = pkgs-unstable.spotify.version;
    meta = pkgs-unstable.spotify.meta;
    paths = [
      pkgs-unstable.spotify
    ];
    buildInputs = [
      pkgs-unstable.makeWrapper
    ];
    postBuild = ''
      wrapProgram $out/bin/spotify \
      --add-flags "--disable-gpu"
    '';
  };
in {
  imports = [
    inputs.spicetify-nix.nixosModules.default
  ];
  options = {
    xanterella = {
      spicetify = {
        enable = lib.mkEnableOption "Aktiviert spicetify";
      };
    };
  };

  config = lib.mkIf config.xanterella.spicetify.enable {
    environment = {
      systemPackages = [
        pkgs-unstable.spotify-player
        pkgs.sptlrx
        (lib.hiPrio (pkgs.makeDesktopItem {
          name = "spotify";
          desktopName = "Spotify";
          icon = "spotify-client";
          exec = "/run/current-system/sw/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
          tryExec = "/run/current-system/sw/bin/spotify";
          terminal = false;
          type = "Application";
          categories = ["Audio" "Music" "Player" "AudioVideo"];
        }))
      ];
    };
    programs = {
      spicetify = {
        enable = true;
        spotifyPackage = spotify-fix;
        enabledExtensions = with spicePkgs.extensions; [
          hidePodcasts
          shuffle
        ];
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
      };
    };
  };
}
