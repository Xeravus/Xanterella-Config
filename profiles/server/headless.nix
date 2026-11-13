{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    xanterella = {
      sddm = {
        enable = false;
      };
      gdm = {
        enable = false;
      };
      lightdm = {
        enable = false;
      };
    };

    systemd = {
      targets = {
        sleep = {
          enable = false;
        };
        suspend = {
          enable = false;
        };
        hibernate = {
          enable = false;
        };
        hybrid-sleep = {
          enable = false;
        };
      };
    };

    services = {
      logind = {
        settings = {
          Login = {
            HandleLidSwitch = "ignore";
            HandleLidSwitchExternalPower = "ignore";
            HandleLidSwitchDocked = "ignore";
            IdleAction = "ignore";
          };
        };
      };
    };
    networking.networkmanager.wifi.powersave = false;

    boot = {
      kernelParams = [
        "console=ttyS0,115200n8"
      ];
    };
  };
}
