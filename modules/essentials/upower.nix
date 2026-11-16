{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.upower.enable {
    environment = {
      systemPackages = with pkgs; [
        upower
      ];
    };
    services = {
      upower = {
        criticalPowerAction = "PowerOff";
        enable = true;
        percentageAction = 3;
        percentageCritical = 5;
        percentageLow = 15;
        usePercentageForPolicy = true;
      };
    };
  };
  options = {
    xanterella = {
      upower = {
        enable = lib.mkEnableOption "Aktiviert upower";
      };
    };
  };
}