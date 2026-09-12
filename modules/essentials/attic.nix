{
  config,
  pkgs,
  pkgs-unstable,
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
    networking = {
      nameservers = ["100.100.100.100"];
      search = ["gute-nessie.ts.net"];
    };
    environment = {
      systemPackages = with pkgs-unstable; [
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
              ExecStart = "${pkgs.attic-client}/bin/attic watch-store xanterella:main -j 1";
              Restart = "always";
              RestartSec = "10";
            };
          };
        };
      };
    };
  };
}
