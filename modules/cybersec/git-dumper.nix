{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.git-dumper.enable {
    environment = {
      systemPackages = with pkgs; [
        git-dumper
      ];
    };
  };
  options = {
    xanterella = {
      git-dumper = {
        enable = lib.mkEnableOption "Aktiviert git-dumper";
      };
    };
  };
}