{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.direnv.enable {
    programs = {
      direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
        };
        settings = {
          log_format = "";
        };
        silent = true;
      };
    };
  };
  options = {
    xanterella = {
      direnv = {
        enable = lib.mkEnableOption "Aktiviert direnv";
      };
    };
  };
}