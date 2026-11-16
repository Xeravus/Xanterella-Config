{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.plymouth.enable {
    boot = {
      plymouth = {
        enable = true;
      };
    };
    environment = {
      systemPackages = with pkgs; [
        plymouth
      ];
    };
  };
  options = {
    xanterella = {
      plymouth = {
        enable = lib.mkEnableOption "Aktiviert plymouth";
      };
    };
  };
}