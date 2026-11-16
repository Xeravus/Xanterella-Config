{
  config,
  lib,
  pkgs,
  pkgs-bleeding,
  ...
}: {
  config = lib.mkIf config.xanterella.netbird.enable {
    age = {
      secrets = {
        netbird-env = {
          file = ./../agenix/netbird.env.age;
        };
      };
    };
    networking = {
      firewall = {
        allowedUDPPorts = [
          51820
        ];
      };
    };
    services = {
      netbird = {
        clients = {
          "${config.networking.hostName}" = {
            autoStart = true;
            login = {
              enable = true;
              setupKeyFile = config.age.secrets.netbird-env.path;
            };
            port = 51820;
          };
        };
        enable = true;
        package = pkgs-bleeding.netbird;
      };
    };
  };
  options = {
    xanterella = {
      netbird = {
        enable = lib.mkEnableOption "Aktiviert netbird als Client";
      };
    };
  };
}