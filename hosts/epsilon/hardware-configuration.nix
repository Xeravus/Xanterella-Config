{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
  ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b36a59cb-d3a4-4fd8-aae1-31ffb57494d7";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C011-DFF2";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  swapDevices = [ ];
}