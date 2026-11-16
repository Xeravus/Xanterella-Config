{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.stress.enable {
    environment = {
      systemPackages = with pkgs; [
        stress
      ];
    };
  };
  options = {
    xanterella = {
      stress = {
        enable = lib.mkEnableOption "Aktiviert Stress ein stress testing package";
      };
    };
  };
}