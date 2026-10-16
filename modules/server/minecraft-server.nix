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
    services = {
      minecraft-server = {
        enable = true;
        eula = true;
        openFirewall = true;
        declarative = true;
        serverProperties = {
          server-port = 25565;
          motd = "Xanterella MC Server - NixOS";
          difficulty = "normal";
          gamemode = "creative";
          max-players = 20;
          simulation-distance = 12;
          view-distance = 10;
        };
      };
    };
  };
}
