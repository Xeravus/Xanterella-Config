{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.zip.enable {
    environment = {
      systemPackages = with pkgs; [
        zip
        unzip
      ];
    };
  };
  options = {
    xanterella = {
      zip = {
        enable = lib.mkEnableOption "Aktiviert ziptools";
      };
    };
  };
}