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
    # Das Overlay wird zwingend benötigt, um Zugriff auf pkgs.fabricServers zu bekommen
    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers = {
        main = {
          enable = true;
          package = pkgs.papermc;
          openFirewall = true;
          serverProperties = {
            server-port = 25565;
            motd = "Xanterella MC Server - NixOS";
            difficulty = "normal";
            gamemode = "survival";
            max-players = 20;
            simulation-distance = 12;
            view-distance = 12;
            force-gamemode = true;
          };
        };

        macepvp = {
          enable = true;
          package = pkgs.fabricServers.fabric-1-21-1;
          openFirewall = true;
          serverProperties = {
            server-port = 25566;
            level-name = "mace-world";
            motd = "Mace PvP Practice";
            difficulty = "normal";
            gamemode = "adventure";
          };

          symlinks."mods/carpet-pvp.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Qx4z0p2E/versions/K3B6FzS4/carpet-pvp-1.21-1.0.0.jar";
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        };
      };
    };
  };
}
