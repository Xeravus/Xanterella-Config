{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}: {
  config = lib.mkIf config.xanterella.amd.enable {
    boot = {
      initrd = {
        kernelModules = [
          "amdgpu"
        ];
      };
    };
    environment.systemPackages = with pkgs-unstable; [
      rocmPackages.rocm-smi
    ];
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    services.xserver.videoDrivers = [
      "amdgpu"
    ];
  };
  options = {
    xanterella = {
      amd = {
        enable = lib.mkEnableOption "Aktiviere AMD Support und AMD Driver";
      };
    };
  };
}