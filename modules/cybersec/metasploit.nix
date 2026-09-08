{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    xanterella = {
      metasploit = {
        enable = lib.mkEnableOption "Aktiviert metasploit";
      };
    };
  };

  config = lib.mkIf config.xanterella.metasploit.enable {
    environment = {
      systemPackages = with pkgs; [
        metasploit
      ];
    };
    networking.firewall.allowedTCPPorts = [4848];
  };
}
