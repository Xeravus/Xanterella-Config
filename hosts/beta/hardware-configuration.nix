{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  boot.extraModulePackages = [ ];
  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "firewire_ohci"
    "xhci_pci"
    "xhci_pci_renesas"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
  ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1058f81d-0fa5-4acb-830c-30b062fa2fa7";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BA54-BA13";
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
}