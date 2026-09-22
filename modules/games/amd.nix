{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  options = {
    xanterella = {
      amd = {
        enable = lib.mkEnableOption "Aktiviere AMD Support und AMD Driver";
      };
    };
  };

  config = lib.mkIf config.xanterella.amd.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    boot = {
      initrd = {
        kernelModules = [
          "amdgpu"
        ];
      };
    };
    services.xserver.videoDrivers = ["amdgpu"];
    environment.systemPackages = with pkgs-unstable; [
      rocmPackages.rocm-smi
    ];
  };
}
