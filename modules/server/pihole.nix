{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.pihole.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [
          53
          80
        ];
        allowedUDPPorts = [
          53
        ];
      };
    };
    virtualisation = {
      oci-containers = {
        backend = "podman";
        containers = {
          pihole = {
            environment = {
              TZ = "Europe/Berlin";
              WEBPASSWORD = "Extremsicherespasswort";
            };
            image = "pihole/pihole:latest";
            ports = [
              "53:53/tcp"
              "53:53/udp"
              "80:80/tcp"
            ];
            volumes = [
              "/var/lib/pihole:/etc/pihole"
              "/var/lib/dnsmasq.d:/etc/dnsmasq.d"
            ];
          };
        };
      };
      podman = {
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      pihole = {
        enable = lib.mkEnableOption "Aktiviert pihole";
      };
    };
  };
}