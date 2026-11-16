{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.boot.enable {
      boot = {
        kernelPackages = pkgs.linuxPackages_6_12;
        kernelParams = [
          "btusb.enable_autosuspend=0"
        ];
        loader = {
          efi = {
            canTouchEfiVariables = true;
          };
          systemd-boot = {
            enable = true;
          };
        };
      };
    })
    (lib.mkIf config.xanterella.boot-server.enable {
      boot = {
        kernelPackages = pkgs.linuxPackages_6_12;
        kernelParams = [
          "btusb.enable_autosuspend=0"
        ];
        loader = {
          efi = {
            canTouchEfiVariables = true;
          };
          grub = {
            enable = false;
          };
          systemd-boot = {
            enable = true;
          };
        };
      };
    })
    (lib.mkIf config.xanterella.boot-vicuna.enable {
      boot = {
        kernelParams = [
          "btusb.enable_autosuspend=0"
        ];
        loader = {
          efi = {
            canTouchEfiVariables = true;
          };
          grub = {
            enable = lib.mkForce false;
          };
          systemd-boot = {
            enable = lib.mkForce false;
          };
        };
      };
    })
  ];
  options = {
    xanterella = {
      boot = {
        enable = lib.mkEnableOption "Aktiviert Grub als bootloader";
      };
      boot-server = {
        enable = lib.mkEnableOption "Aktiviert Bootoptions für Servers";
      };
      boot-vicuna = {
        enable = lib.mkEnableOption "Aktiviert Bootoptions für Raspberry Pi Server";
      };
    };
  };
}