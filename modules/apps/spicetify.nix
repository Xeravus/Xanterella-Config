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
    buildInputs = [
      pkgs-unstable.makeWrapper
    ];
    meta = pkgs-unstable.spotify.meta;
    name = "spotify-fix";
    paths = [
      pkgs-unstable.spotify
    ];
    pname = "spotify";
    postBuild = ''
      wrapProgram $out/bin/spotify \
      --add-flags "--disable-gpu"
    '';
    version = pkgs-unstable.spotify.version;
  };
in {
    config = lib.mkIf config.xanterella.spicetify.enable {
      environment = {
        systemPackages = [
          pkgs-unstable.spotify-player
          pkgs.sptlrx
          (lib.hiPrio (pkgs.makeDesktopItem {
            categories = [
              "Audio"
              "Music"
              "Player"
              "AudioVideo"
            ];
            desktopName = "Spotify";
            exec = "/run/current-system/sw/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
            icon = "spotify-client";
            name = "spotify";
            terminal = false;
            tryExec = "/run/current-system/sw/bin/spotify";
            type = "Application";
          }))
        ];
      };
      programs = {
        spicetify = {
          colorScheme = "mocha";
          enable = true;
          enabledExtensions = with spicePkgs.extensions; [
            hidePodcasts
            shuffle
          ];
          spotifyPackage = spotify-fix;
          theme = spicePkgs.themes.catppuccin;
        };
      };
    };
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
  }