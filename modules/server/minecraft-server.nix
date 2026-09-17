{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  options = {
    xanterella = {
      minecraft-server = {
        enable = lib.mkEnableOption "Aktiviert minecraft-server";
      };
    };
  };

  config = lib.mkIf config.xanterella.minecraft-server.enable {
    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services = {
      minecraft-servers = {
        enable = true;
        eula = true;
        # package = pkgs.neoforgeServer.neoforge-1_21_1;
        servers = {
          bagetti = {
            enable = true;
            declarative = true;
            serverProperties = {
              server-port = 25565;
              gamemode = "survival";
              max-players = 20;
            };
          };
        };
      };
    };
  };
}
