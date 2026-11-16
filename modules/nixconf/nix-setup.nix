{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xanterella.nix-setup;
  nix-setup = pkgs.writeShellScriptBin "nix-setup" ''
    sudo systemctl enable sshd
    sudo systemctl start sshd
    git config --global user.name "Xeravus"
    git config --global user.name
    git config --global user.email "cato.jenisch@gmail.com"
    git config --global user.email
      gh auth login --hostname github.com --web -p https
    sudo tailscale up --hostname crylia
  '';
in {
    config = lib.mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs; [
          nix-setup
        ];
      };
    };
    options = {
      xanterella = {
        nix-setup = {
          enable = lib.mkEnableOption "Aktiviert das Nix-Setup Script";
        };
      };
    };
  }