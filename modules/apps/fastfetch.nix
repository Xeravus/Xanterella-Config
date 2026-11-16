{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.fastfetch.enable {
    environment = {
      systemPackages = with pkgs; [
        fastfetch
      ];
    };
  };
  options = {
    xanterella = {
      fastfetch = {
        enable = lib.mkEnableOption "Aktiviert fastfetch";
      };
    };
  };
}