{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  p10kConf = ./p10k.zsh;

  yaziFunc = ''
    function y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      command yazi "$@" --cwd-file="$tmp"
      IFS= read -r -d "" cwd < "$tmp"
      [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
      rm -f -- "$tmp"
    }
  '';
  userZshrc = pkgs.writeText "zshrc" ''
    # 1. Cache & Instant Prompt (prompt_cr ist hier bereits durch NixOS deaktiviert!)
    ZSH_CACHE_DIR="$HOME/.cache/zsh"
    if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
      mkdir -p "$ZSH_CACHE_DIR"
    fi
    export ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-$HOST-$ZSH_VERSION"
    export DIRENV_LOG_FORMAT=""

    #if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
    #  source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
    #fi

    #source ${inputs.p10k-src}/powerlevel10k.zsh-theme
    #source ${p10kConf}
    ${yaziFunc}

    eval "$(starship init zsh)"

    #(( ! ''${+functions[p10k]} )) || p10k finalize
  '';
in {
  options = {
    xanterella = {
      zsh = {
        enable = lib.mkEnableOption "Aktiviert zsh";
      };
      bash = {
        enable = lib.mkEnableOption "Aktiviert Bash";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.xanterella.zsh.enable {
      environment = {
        systemPackages = with pkgs; [
          bat
          eza
          jq
          #starship
        ];
      };

      systemd = {
        user = {
          tmpfiles = {
            rules = [
              "L+ %h/.zshrc - - - - ${userZshrc}"
            ];
          };
        };
      };

      users = {
        defaultUserShell = pkgs.zsh;
      };

      programs = {
        zsh = {
          enable = true;
          enableCompletion = true;
          enableBashCompletion = true;
          enableLsColors = true;
          autosuggestions = {
            enable = true;
          };
          syntaxHighlighting = {
            enable = true;
          };

          promptInit = "";

          setOptions = [
            "NO_NOMATCH"
            "NO_PROMPT_CR"
          ];

          shellAliases = {
            l = "eza --icons -lha";
            ls = "eza --icons";
            tree = "eza --tree --icons";
            cl = "clear";
            f = "fastfetch";
            v = "nvim";
            vim = "nvim";
            sv = "sudo nvim";
            nix-pr = "nixpkgs-review pr --print-result";
            b = "btop";
            carrun = "cargo c && cargo t && cargo b";
            pcl = "pyroclear && clear";
            plc = "pyroclear && clear";
            p = "pyroclear && clear";
            cat = "bat";
            thm = "sudo openvpn ~/tryhackme/VPN/tryhackme.ovpn";

            alpha = "ssh cato@alpha";
            beta = "ssh cato@beta";
            gamma = "ssh cato@lacrux";
            delta = "ssh cato@delta";
            epsilon = "ssh cato@epsilon";
            zeta = "ssh cato@zeta";
          };

          interactiveShellInit = "";
        };
        zoxide = {
          enable = true;
          enableZshIntegration = true;
        };
        starship = {
          enable = true;
          settings = {
            "$schema" = "https://starship.rs/schema/starship-schema.json";

            format = ''
              [](mauve)\
              $custom\
              [](bg:surface2 fg:mauve)\
              $directory\
              [](bg:surface1 fg:surface2)\
              $git_branch\
              $git_status\
              [](bg:surface0 fg:surface1)\
              $rust\
              [](fg:surface0)\
              $line_break\
              [](mauve)$character'';

            palette = "catppuccin_mocha";

            palettes.catppuccin_mocha = {
              rosewater = "#f5e0dc";
              flamingo = "#f2cdcd";
              pink = "#f5c2e7";
              mauve = "#cba6f7";
              red = "#f38ba8";
              maroon = "#eba0ac";
              peach = "#fab387";
              yellow = "#f9e2af";
              green = "#a6e3a1";
              teal = "#94e2d5";
              sky = "#89dceb";
              sapphire = "#74c7ec";
              blue = "#89b4fa";
              lavender = "#b4befe";
              text = "#cdd6f4";
              subtext1 = "#bac2de";
              subtext0 = "#a6adc8";
              overlay2 = "#9399b2";
              overlay1 = "#7f849c";
              overlay0 = "#6c7086";
              surface2 = "#585b70";
              surface1 = "#45475a";
              surface0 = "#313244";
              base = "#1e1e2e";
              mantle = "#181825";
              crust = "#11111b";
            };

            custom.username = {
              command = ''echo "$USER@$(hostname)"'';
              style = "bg:mauve fg:crust";
              format = "[ $output ]($style)";
              when = true;
            };

            directory = {
              style = "fg:mauve bg:surface2";
              format = "[ $path ]($style)";
            };

            git_branch = {
              symbol = "";
              style = "bg:surface1";
              format = "[[ $symbol ](fg:maroon bg:surface1)]($style)";
            };

            git_status = {
              style = "bg:surface1";
              format = "[[($all_status$ahead_behind )](fg:maroon bg:surface1)]($style)";
            };

            rust = {
              symbol = "";
              style = "bg:surface0";
              format = "[[ $symbol( $version) ](fg:peach bg:surface0)]($style)";
            };

            line_break = {
              disabled = false;
            };

            character = {
              disabled = false;
              success_symbol = "[>](bold fg:teal)";
              error_symbol = "[>](bold fg:red)";
            };
          };
        };
      };

      users = {
        users = {
          cato = {
            shell = pkgs.zsh;
          };
          root = {
            shell = pkgs.zsh;
          };
        };
      };
    })

    (lib.mkIf config.xanterella.bash.enable {
      programs.bash = {
        completion.enable = true;
        shellAliases = {
          l = "ls -lha";
          cl = "clear";
          f = "fastfetch";
          v = "nvim";
          vim = "nvim";
          sv = "sudo nvim";
          za = "yazi";
          nix-pr = "nixpkgs-review pr --print-result";
        };
      };
      users.users = {
        cato.shell = pkgs.bash;
        root.shell = pkgs.bash;
      };
    })
  ];
}
