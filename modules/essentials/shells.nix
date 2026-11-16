{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  userZshrc = pkgs.writeText "zshrc" ''
    # 1. Cache & Instant Prompt (prompt_cr ist hier bereits durch NixOS deaktiviert!)
    ZSH_CACHE_DIR="$HOME/.cache/zsh"
    if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
      mkdir -p "$ZSH_CACHE_DIR"
    fi
    export ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-$HOST-$ZSH_VERSION"
    export DIRENV_LOG_FORMAT=""

    ${yaziFunc}
  '';
  yaziFunc = ''
    function y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      command yazi "$@" --cwd-file="$tmp"
      IFS= read -r -d "" cwd < "$tmp"
      [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
      rm -f -- "$tmp"
    }
  '';
in {
    config = lib.mkMerge [
      (lib.mkIf config.xanterella.zsh.enable {
        environment = {
          systemPackages = with pkgs; [
            bat
            eza
            jq
          ];
        };
        programs = {
          starship = {
            enable = true;
            package = pkgs.starship;
            settings = {
              "$schema" = "https://starship.rs/schema/starship-schema.json";
              character = {
                disabled = false;
                error_symbol = "[>](bold fg:red)";
                success_symbol = "[>](bold fg:teal)";
              };
              custom = {
                username = {
                  command = ''echo "$USER@$(hostname)"'';
                  format = "[ $output ]($style)";
                  style = "bg:mauve fg:crust";
                  when = true;
                };
              };
              directory = {
                format = "[ $path ]($style)";
                style = "fg:mauve bg:surface2";
                truncation_length = 50;
              };
              format = "$custom[](bg:surface2 fg:mauve)$directory[](bg:surface1 fg:surface2)$git_branch$git_status[](bg:surface0 fg:surface1)$rust[](fg:surface0)$line_break$character";
              git_branch = {
                format = "[[ $symbol ](fg:maroon bg:surface1)]($style)";
                style = "bg:surface1";
                symbol = "";
              };
              git_status = {
                format = "[[($all_status$ahead_behind )](fg:maroon bg:surface1)]($style)";
                style = "bg:surface1";
              };
              line_break = {
                disabled = false;
              };
              palette = "catppuccin_mocha";
              palettes = {
                catppuccin_mocha = {
                  base = "#1e1e2e";
                  blue = "#89b4fa";
                  crust = "#11111b";
                  flamingo = "#f2cdcd";
                  green = "#a6e3a1";
                  lavender = "#b4befe";
                  mantle = "#181825";
                  maroon = "#eba0ac";
                  mauve = "#cba6f7";
                  overlay0 = "#6c7086";
                  overlay1 = "#7f849c";
                  overlay2 = "#9399b2";
                  peach = "#fab387";
                  pink = "#f5c2e7";
                  red = "#f38ba8";
                  rosewater = "#f5e0dc";
                  sapphire = "#74c7ec";
                  sky = "#89dceb";
                  subtext0 = "#a6adc8";
                  subtext1 = "#bac2de";
                  surface0 = "#313244";
                  surface1 = "#45475a";
                  surface2 = "#585b70";
                  teal = "#94e2d5";
                  text = "#cdd6f4";
                  yellow = "#f9e2af";
                };
              };
              rust = {
                format = "[[ $symbol( $version) ](fg:peach bg:surface0)]($style)";
                style = "bg:surface0";
                symbol = "";
              };
            };
          };
          zoxide = {
            enable = true;
            enableZshIntegration = true;
          };
          zsh = {
            autosuggestions = {
              enable = true;
            };
            enable = true;
            enableBashCompletion = true;
            enableCompletion = true;
            enableLsColors = true;
            interactiveShellInit = "";
            promptInit = "";
            setOptions = [
              "NO_NOMATCH"
              "NO_PROMPT_CR"
            ];
            shellAliases = {
              alpha = "ssh cato@alpha";
              b = "btop";
              beta = "ssh cato@beta";
              carrun = "cargo c && cargo t && cargo b";
              cat = "bat";
              cl = "clear";
              delta = "ssh cato@delta";
              epsilon = "ssh cato@epsilon";
              f = "fastfetch";
              gamma = "ssh cato@lacrux";
              l = "eza --icons -lha";
              larp = "cargo clean -q && cargo build --vv -r";
              ls = "eza --icons";
              nix-pr = "nixpkgs-review pr --print-result";
              p = "pyroclear && clear";
              pcl = "pyroclear && clear";
              plc = "pyroclear && clear";
              sv = "sudo nvim";
              thm = "sudo openvpn ~/tryhackme/VPN/tryhackme.ovpn";
              tree = "eza --tree --icons";
              v = "nvim";
              vim = "nvim";
              zeta = "ssh cato@zeta";
            };
            syntaxHighlighting = {
              enable = true;
            };
          };
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
            cl = "clear";
            f = "fastfetch";
            l = "ls -lha";
            nix-pr = "nixpkgs-review pr --print-result";
            sv = "sudo nvim";
            v = "nvim";
            vim = "nvim";
            za = "yazi";
          };
        };
        users.users = {
          cato.shell = pkgs.bash;
          root.shell = pkgs.bash;
        };
      })
    ];
    options = {
      xanterella = {
        bash = {
          enable = lib.mkEnableOption "Aktiviert Bash";
        };
        zsh = {
          enable = lib.mkEnableOption "Aktiviert zsh";
        };
      };
    };
  }