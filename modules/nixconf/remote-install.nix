{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xanterella.remote-install;
  remote-install = pkgs.writeShellScriptBin "remote-install" ''
    tailscale status | grep tagged-devices
    read TARGET_IP
    cd
    cd xanterella
    echo "Starte Installation auf $TARGET_IP..."
    ssh root@$TARGET_IP 'echo "unsetopt nomatch" > ~/.zshenv'
    notify-send "Starte Remote-Install"
    sleep 3
    nix run github:numtide/nixos-anywhere -- --flake .#crylia root@$TARGET_IP
    notify-send "Beendet Remote-Install"
  '';
in {
    config = lib.mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs; [
          remote-install
        ];
      };
    };
    options = {
      xanterella = {
        remote-install = {
          enable = lib.mkEnableOption "Aktiviert das Remote-Install Script";
        };
      };
    };
  }