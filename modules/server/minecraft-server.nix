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
        package = pkgs.papermc;
        openFirewall = true;
        declarative = true;
        serverProperties = {
          server-port = 25565;
          motd = "Xanterella MC Server - NixOS";
          difficulty = "normal";
          gamemode = "survival";
          max-players = 20;
          simulation-distance = 12;
          view-distance = 10;
          force-gamemode = true;
          management-server-enabled = true;
          management-server-host = "beta.gute-nessie.ts.net";
          management-server-port = 25566;
          #management-server-secret = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
          management-server-tls-enabled = false;
          enable-rcon = true;
          "rcon.port" = 25575;
          "rcon.passwort" = "Extremsehrunfassbarsicherespasswortnatürlichgehasht";
        };
      };
    };
  };
}
