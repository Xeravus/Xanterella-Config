{
  config,
  pkgs-unstable,
  lib,
  ...
}: {
  options = {
    xanterella = {
      davinci = {
        enable = lib.mkEnableOption "Aktiviert davinci";
      };
    };
  };

  config = lib.mkIf config.xanterella.davinci.enable {
    environment = {
      systemPackages = with pkgs-unstable; [
        davinci-resolve
      ];
    };
  };
}
