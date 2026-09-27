{
  config,
  lib,
  ...
}: let
  cfg = config.xanterella.makemkv;
  nodeCfg = config.xanterella.cluster-node;
in {
  options = {
    xanterella = {
      makemkv = {
        enable = lib.mkEnableOption "Aktiviert MakeMKV Web-GUI";
      };
    };
  };

  config = lib.mkIf (cfg.enable && nodeCfg.enable) {
    xanterella = {
      vlc = {
        enable = true;
      };
    };
    virtualisation = {
      oci-containers = {
        containers = {
          arm = {
            image = "automaticrippingmachine/automatic-ripping-machine:latest";
            ports = ["0.0.0.0:8988:8080"];
            volumes = [
              "/mnt/server-data/arm/etc:/etc/arm/config"
              "/mnt/server-data/arm/home:/home/arm/media"
            ];
            environment = {
              PUID = "1000";
              #PGID = "Gruppen-ID-von-media";
            };
            extraOptions = [
              "--device=/dev/sr0:/dev/sr0"
              "--privileged"
            ];
          };
        };
      };
    };
    boot = {
      kernelModules = ["sg"];
    };
    systemd = {
      tmpfiles = {
        rules = [
          "d /mnt/server-data/arm 0777 root root -"
          "d /mnt/server-data/arm/home 0777 root root -"
          "d /mnt/server-data/arm/etc 0777 root root -"
        ];
      };
    };
    users = {
      users = {
        cato = {
          extraGroups = ["cdrom" "video"];
        };
      };
    };
  };
}
