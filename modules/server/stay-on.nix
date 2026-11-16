{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.stay-on.enable {
    boot = {
      kernelParams = [
        "consoleblank=60"
      ];
    };
    services = {
      logind = {
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
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
  };
  options = {
    xanterella = {
      stay-on = {
        enable = lib.mkEnableOption "Lässt das Gerät nicht ausgehen";
      };
    };
  };
}