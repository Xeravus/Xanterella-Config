{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.wireshark.enable {
    environment = {
      systemPackages = with pkgs; [
        wireshark
      ];
    };
  };
  options = {
    xanterella = {
      wireshark = {
        enable = lib.mkEnableOption "Aktiviert wireshark";
      };
    };
  };
}