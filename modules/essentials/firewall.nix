{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.firewall.enable {
    networking = {
      firewall = {
        allowPing = true;
        allowedTCPPorts = [
          22
          80
          443
        ];
        allowedUDPPorts = [ ];
        enable = true;
        trustedInterfaces = [
          "tailscale0"
        ];
      };
      nftables = {
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      firewall = {
        enable = lib.mkEnableOption "Aktiviert firewall";
      };
    };
  };
}