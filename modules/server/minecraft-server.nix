{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  config = lib.mkIf config.xanterella.minecraft-server.enable {
    environment = {
      systemPackages = [
        pkgs.mcrcon
      ];
    };
    services = {
      minecraft-server = {
        declarative = true;
        enable = true;
        eula = true;
        openFirewall = true;
        package = pkgs.papermc;
        serverProperties = {
          "rcon.password" = "DeinSicheresPasswort";
          "rcon.port" = 25575;
          difficulty = "normal";
          enable-rcon = true;
          force-gamemode = true;
          gamemode = "survival";
          management-server-enabled = true;
          management-server-host = "beta.gute-nessie.ts.net";
          management-server-port = 25566;
          management-server-tls-enabled = false;
          max-players = 20;
          motd = "Xanterella MC Server - NixOS";
          server-port = 25565;
          simulation-distance = 12;
          view-distance = 10;
        };
      };
    };
  };
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
}