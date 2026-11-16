{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.lightdm.enable {
      services.xserver.displayManager.lightdm.enable = true;
      services.xserver.displayManager.lightdm.greeters.gtk.enable = true;
    })
    (lib.mkIf (!config.xanterella.lightdm.enable) {
      services.xserver.displayManager.lightdm.enable = false;
      services.xserver.displayManager.lightdm.greeters.gtk.enable = false;
    })
  ];
  options = {
    xanterella = {
      lightdm = {
        enable = lib.mkEnableOption "Aktiviert LightDm";
      };
    };
  };
}