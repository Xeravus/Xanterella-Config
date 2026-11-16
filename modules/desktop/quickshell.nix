{
  config,
  pkgs,
  lib,
  pkgs-new,
  inputs,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.quickshell.enable {
      environment = {
        systemPackages = with pkgs-new; [
          quickshell
        ];
        variables = {
          QML_XHR_ALLOW_FILE_READ = "1";
        };
      };
    })
    (lib.mkIf config.xanterella.quickshell_noctalia.enable {
      environment = {
        systemPackages = [
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    })
  ];
  options = {
    xanterella = {
      quickshell = {
        enable = lib.mkEnableOption "Aktiviert quickshell";
      };
      quickshell_noctalia = {
        enable = lib.mkEnableOption "Aktiviert Quickshell mit der Noctalia Shell";
      };
    };
  };
}