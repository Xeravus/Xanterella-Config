{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.bluetooth.enable {
    environment = {
      systemPackages = with pkgs; [
        bluetui
      ];
    };
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            FastConnectable = "true";
          };
        };
      };
    };
    powerManagement = {
      resumeCommands = ''
                sleep 2
                       ${pkgs.bluez}/bin/bluetoothctl power on
              sleep 3
        ${pkgs.bluez}/bin/bluetoothctl connect 84:D3:52:2A:B5:97
      '';
    };
  };
  options = {
    xanterella = {
      bluetooth = {
        enable = lib.mkEnableOption "Aktiviert bluetooth";
      };
    };
  };
}