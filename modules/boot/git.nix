{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.git.enable {
    environment = {
      systemPackages = with pkgs; [
        git
        lazygit
        gh
        git-lfs
      ];
    };
    programs = {
      git = {
        config = {
          alias = {
            br = "branch";
            ch = "checkout";
            ck = "checkout";
            cm = "commit -am";
            df = "diff --stat";
            st = "status";
          };
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
          user = {
            email = "cato.jenisch@gmail.com";
            name = "Xeravus";
          };
        };
        enable = true;
      };
    };
  };
  options = {
    xanterella = {
      git = {
        enable = lib.mkEnableOption "Aktiviert git und nützliche git tools";
      };
    };
  };
}