{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    boot = {
      kernelParams = [
        "console=ttyS0,115200n8"
      ];
    };
    networking.networkmanager.wifi.powersave = false;
    services = {
      logind = {
        settings = {
          Login = {
            HandleLidSwitch = "ignore";
            HandleLidSwitchDocked = "ignore";
            HandleLidSwitchExternalPower = "ignore";
            IdleAction = "ignore";
          };
        };
      };
    };
    systemd = {
      targets = {
        hibernate = {
          enable = false;
        };
        hybrid-sleep = {
          enable = false;
        };
        sleep = {
          enable = false;
        };
        suspend = {
          enable = false;
        };
      };
    };
    xanterella = {
      gdm = {
        enable = false;
      };
      lightdm = {
        enable = false;
      };
      sddm = {
        enable = false;
      };
    };
  };
}