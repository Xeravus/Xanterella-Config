{
  config,
  pkgs,
  lib,
  ...
}: let
  kittyConf = pkgs.writeText "kitty.conf" ''
    font_family                     GeistMono Nerd Font Mono
    font_size                       12

    single_instance 		    yes

    disable_ligatures               no
    enable_audio_bell               no

    shell                           zsh
    shell_integration               disable

    cursor_shape                    block

    url_style                       curly

    remember_window_size            no
    initial_window_width            640
    initial_window_height           480
    window_padding_width            5

    background_opacity              0.25

    confirm_os_window_close         0

    sync_to_monitor                 no

    include ${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Mocha.conf
    include ~/.config/kitty/themes/noctalia.conf
  '';

  kittywrapped = pkgs.symlinkJoin {
    name = "kitty-wrapped";
    paths = [
      pkgs.kitty
    ];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/kitty \
        --add-flags "--config ${kittyConf}"
    '';
  };
in {
  options = {
    xanterella = {
      kitty = {
        enable = lib.mkEnableOption "Aktiviert kitty";
      };
    };
  };

  config = lib.mkIf config.xanterella.kitty.enable {
    environment = {
      systemPackages = [
        kittywrapped
        pkgs.tmux
        pkgs.kitty-themes
      ];
    };
    programs = {
      tmux = {
        clock24 = true;
        keyMode = "vi";
        baseIndex = 1;
      };
    };
  };
}
