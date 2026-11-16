{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.tokei.enable {
    environment = {
      systemPackages = with pkgs; [
        tokei
      ];
    };
  };
  options = {
    xanterella = {
      tokei = {
        enable = lib.mkEnableOption "Aktiviert tokei";
      };
    };
  };
}