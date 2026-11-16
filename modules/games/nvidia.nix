{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  config = lib.mkIf config.xanterella.nvidia.enable {
    boot = {
      kernelParams = [
        "nvidia-drm.modeset=1"
      ];
    };
    environment = {
      sessionVariables = {
        GDM_BACKEND = "nvidia-drm";
        LIBVA_DRIVE_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };
      nvidia = {
        modesetting = {
          enable = true;
        };
        open = true;
        powerManagement = {
          enable = true;
        };
        prime = {
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
          sync = {
            enable = true;
          };
        };
      };
    };
    services = {
      xserver = {
        enable = true;
        videoDrivers = [
          "nvidia"
        ];
      };
    };
  };
  options = {
    xanterella = {
      nvidia = {
        enable = lib.mkEnableOption "Aktiviere Nvidia Support und Nvidia Driver";
      };
    };
  };
}