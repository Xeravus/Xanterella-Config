{
  config,
  pkgs,
  lib,
  pkgs-new,
  inputs,
  ...
}: {
  config = lib.mkIf config.xanterella.nixvim.enable {
    environment = {
      systemPackages = with pkgs; [
        ripgrep
        qt6.qtdeclarative
        kdePackages.qtdeclarative
      ];
    };
    programs = {
      nixvim = {
        colorschemes = {
          catppuccin = {
            autoLoad = true;
            enable = true;
          };
        };
        defaultEditor = true;
        enable = true;
        extraPackages = with pkgs-new; [
          alejandra
        ];
        globals = {
          mapleader = " ";
        };
        keymaps = [
          {
            action = "<Nop>";
            key = "<Up>";
            mode = [
              "n"
              "i"
              "v"
            ];
          }
          {
            action = "<Nop>";
            key = "<Down>";
            mode = [
              "n"
              "i"
              "v"
            ];
          }
          {
            action = "<Nop>";
            key = "<Left>";
            mode = [
              "n"
              "i"
              "v"
            ];
          }
          {
            action = "<Nop>";
            key = "<Right>";
            mode = [
              "n"
              "i"
              "v"
            ];
          }
          {
            action = "<cmd>bprevious<CR>";
            key = "<S-h>";
            options = {
              desc = "Vorheriger Tab";
            };
          }
          {
            action = "<cmd>bnext<CR>";
            key = "<S-l>";
            options = {
              desc = "Nächster Tab";
            };
          }
          {
            action = "<cmd>bdelete<CR>";
            key = "<leader>x";
            options = {
              desc = "Aktuellen Tab schließen";
            };
          }
          {
            action = "<cmd>lua Snacks.picker.grep()<CR>";
            key = "<leader>fg";
            mode = "n";
            options = {
              desc = "Live Grep";
            };
          }
          {
            action = "<cmd>lua Snacks.picker.treesitter()<CR>";
            key = "<leader>fs";
            mode = "n";
            options = {
              desc = "Funktionen und Struktur (Outline)";
            };
          }
          {
            action = "<cmd>cnext<CR>";
            key = "<leader>j";
            mode = "n";
            options = {
              desc = "Nächster Quickfix-Eintrag";
            };
          }
          {
            action = "<cmd>cprev<CR>";
            key = "<leader>k";
            mode = "n";
            options = {
              desc = "Vorheriger Quickfix-Eintrag";
            };
          }
          {
            action = "<cmd>lua Snacks.picker.projects()<CR>";
            key = "<leader>fp";
            mode = "n";
            options = {
              desc = "Projects";
            };
          }
          {
            action = "<cmd>lua Snacks.terminal.toggle()<CR>";
            key = "<leader>tt";
            mode = [
              "n"
              "t"
            ];
            options = {
              desc = "Terminal umschalten";
            };
          }
          {
            action = "<cmd>lua Snacks.lazygit()<CR>";
            key = "<leader>gg";
            mode = "n";
            options = {
              desc = "Lazygit öffnen";
            };
          }
          {
            action = "<cmd>lua Snacks.explorer()<CR>";
            key = "<leader>ff";
            mode = "n";
            options = {
              desc = "Explorer";
            };
          }
          {
            action = "<cmd>lua Snacks.picker.files()<CR>";
            key = "<C-n>";
            mode = [
              "n"
              "i"
            ];
            options = {
              desc = "Find Files";
            };
          }
        ];
        opts = {
          number = true;
          relativenumber = true;
          shiftwidth = 4;
          termguicolors = true;
        };
        plugins = {
          bufferline = {
            enable = true;
          };
          cmp = {
            enable = true;
            settings = {
              mapping = {
                "<C-Space>" = "cmp.mapping.complete()";
                "<C-n>" = "cmp.mapping.select_next_item()";
                "<C-p>" = "cmp.mapping.select_prev_item()";
                "<S-CR>" = "cmp.mapping.confirm({ select = true })";
              };
              sources = [
                {
                  name = "nvim_lsp";
                }
                {
                  name = "path";
                }
                {
                  name = "buffer";
                }
              ];
            };
          };
          conform-nvim = {
            enable = true;
            settings = {
              format_on_save = {
                lsp_fallback = false;
                timeout_ms = 500;
              };
              formatters_by_ft = {
                nix = [
                  "alejandra"
                ];
                qml = [
                  "qmlformat"
                ];
              };
            };
          };
          gitsigns = {
            enable = true;
          };
          hardtime = {
            enable = true;
          };
          highlight-colors = {
            enable = true;
          };
          lsp = {
            enable = true;
            keymaps = {
              lspBuf = {
                "<leader>ca" = "code_action";
                "K" = "hover";
                "gd" = "definition";
              };
            };
            servers = { };
          };
          lualine = {
            enable = true;
          };
          neogit = {
            enable = true;
          };
          snacks = {
            enable = true;
            settings = {
              bigfile = {
                enable = true;
              };
              dashboard = {
                enable = true;
                sections = [
                  {
                    section = "header";
                  }
                  {
                    gap = 1;
                    padding = 1;
                    section = "keys";
                  }
                  {
                    icon = " ";
                    indent = 2;
                    padding = 1;
                    section = "recent_files";
                    title = "Letzte Dateien";
                  }
                  {
                    icon = " ";
                    indent = 2;
                    padding = 1;
                    section = "projects";
                    title = "Projekte";
                  }
                ];
              };
              explorer = {
                enable = true;
              };
              lazygit = {
                enable = true;
              };
              notifier = {
                enable = true;
              };
              picker = {
                enable = true;
              };
              quickfile = {
                enable = true;
              };
              statuscolumn = {
                enable = true;
              };
              terminal = {
                enable = true;
              };
              words = {
                enable = true;
              };
            };
          };
          treesitter = {
            enable = true;
          };
          vim-be-good = {
            enable = true;
          };
          web-devicons = {
            enable = true;
          };
        };
      };
    };
  };
  imports = [
    inputs.nixvim.nixosModules.default
  ];
  options = {
    xanterella = {
      nixvim = {
        enable = lib.mkEnableOption "Aktiviert Nixvim";
      };
    };
  };
}