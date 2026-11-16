{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  config = lib.mkIf config.xanterella.pyroclear.enable {
    environment = {
      systemPackages = with pkgs; [
        inputs.pyroclear.packages.${pkgs.system}.default
      ];
    };
  };
  options = {
    xanterella = {
      pyroclear = {
        enable = lib.mkEnableOption "Aktiviert pyroclear";
      };
    };
  };
}