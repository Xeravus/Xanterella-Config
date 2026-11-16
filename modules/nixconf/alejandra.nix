{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  inputs,
  ...
}: {
  config = lib.mkIf config.xanterella.alejandra.enable {
    environment = {
      systemPackages = with pkgs-unstable; [
        inputs.alejandra.defaultPackage.${pkgs.system}
      ];
    };
  };
  options = {
    xanterella = {
      alejandra = {
        enable = lib.mkEnableOption "Aktiviert Alejandra";
      };
    };
  };
}