{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  config = lib.mkIf config.xanterella.agenix.enable {
    environment = {
      systemPackages = with pkgs; [
        inputs.agenix.packages.${pkgs.system}.default
      ];
    };
  };
  imports = [
    inputs.agenix.nixosModules.default
  ];
  options = {
    xanterella = {
      agenix = {
        enable = lib.mkEnableOption "Aktiviert agenix";
      };
    };
  };
}