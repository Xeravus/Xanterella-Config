{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.hydra.enable {
    environment = {
      systemPackages = with pkgs; [
        thc-hydra
      ];
    };
  };
  options = {
    xanterella = {
      hydra = {
        enable = lib.mkEnableOption "Aktiviert hydra";
      };
    };
  };
}