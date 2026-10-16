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
    age = {
      secrets = {
        minecraft-rcone = {
          file = ./../agenix/minecraft-rcone.age;
          owner = "minecraft";
          group = "minecraft";
        };
      };
    };
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
          enable-rcon = true;
          "rcon.port" = 25575;
        };
      };
    };

    systemd = {
      services = {
        minecraft-server = {
          preStart = lib.mkAfter ''
            if [ -L server.properties ]; then
              REAL_PROP=$(readlink server.properties)
              rm server.properties
              cp "$REAL_PROP" server.properties
              chmod 600 server.properties
            fi
            echo "rcon.password=$(cat ${config.age.secrets.minecraft-rcone.path})" >> server.properties
          '';
        };
      };
    };
  };
}
