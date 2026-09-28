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
    users = {
      groups = {
        media = {
          gid = 5000;
        };
      };
    };
    virtualisation = {
      oci-containers = {
        containers = {
          arm = {
            image = "automaticrippingmachine/automatic-ripping-machine:latest";
            ports = ["0.0.0.0:8080:8080"];
            volumes = [
              "/mnt/server-data/arm/etc:/etc/arm/config"
              "/mnt/server-data/arm/home:/home/arm/media"
            ];
            environment = {
              ARM_UID = "1000";
              ARM_GID = "5000";
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
          "d /mnt/server-data/arm 0775 cato media -"
          "d /mnt/server-data/arm/home 0775 cato media -"
          "d /mnt/server-data/arm/etc 0775 cato media -"
        ];
      };
    };
    users = {
      users = {
        cato = {
          extraGroups = ["cdrom" "video" "media"];
        };
      };
    };
  };
}
