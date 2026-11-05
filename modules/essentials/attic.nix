{
  config,
  pkgs,
  pkgs-bleeding,
  lib,
  ...
}: {
  options = {
    xanterella = {
      attic = {
        enable = lib.mkEnableOption "Aktiviert attic";
      };
    };
  };

  config = lib.mkIf config.xanterella.attic.enable {
    environment = {
      systemPackages = with pkgs-bleeding; [
        attic-client
      ];
    };
    nix = {
      settings = {
        extra-substituters = [
          "https://attic.xanterella.de/main"
        ];
        extra-trusted-public-keys = [
          "main:hb8AzhhBIUsAT+TOJnzHMC9+WiYlQh9fSGeDxzQgy4s="
        ];
      };
    };
    systemd = {
      user = {
        services = {
          attic-watch-store = {
            description = "Attic watch-store daemon";
            wantedBy = [
              "default.target"
            ];
            after = [
              "network-online.target"
            ];
            serviceConfig = {
              ExecStart = "${pkgs-bleeding.attic-client}/bin/attic watch-store xanterella:main -j 5";
              Restart = "always";
              RestartSec = "600";
            };
          };
        };
      };
    };
  };
}
