{
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.mount-games.enable {
      fileSystems = {
        "/mnt/games" = {
          device = "/dev/disk/by-label/Games";
          fsType = "ext4";
          options = [
            "defaults"
            "nofail"
          ];
        };
      };
    })
  ];
  options = {
    xanterella = {
      mount-games = {
        enable = lib.mkEnableOption "Aktiviert einen automatischen mount für eine Game SSD";
      };
    };
  };
}