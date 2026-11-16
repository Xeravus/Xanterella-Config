{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.lazysql.enable {
    environment = {
      systemPackages = with pkgs; [
        lazysql
      ];
    };
    programs = {
      zsh = {
        shellAliases = {
          sql = "lazysql";
        };
      };
    };
  };
  options = {
    xanterella = {
      lazysql = {
        enable = lib.mkEnableOption "Aktiviert lazysql";
      };
    };
  };
}