{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.metasploit.enable {
    environment = {
      systemPackages = with pkgs; [
        metasploit
      ];
    };
    networking.firewall.allowedTCPPorts = [
      4848
    ];
  };
  options = {
    xanterella = {
      metasploit = {
        enable = lib.mkEnableOption "Aktiviert metasploit";
      };
    };
  };
}