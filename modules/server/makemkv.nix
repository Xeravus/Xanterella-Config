{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.xanterella.makemkv;
  nodeCfg = config.xanterella.cluster-node;
  armUid = "1100";
  armGid = "5500";
  armMediaDir = "/mnt/server-data/arm";
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
            ports = ["0.0.0.0:8080:8080"];
            volumes = [
              "${armMediaDir}/etc:/etc/arm/config"
              "${armMediaDir}/home:/home/arm/media"
            ];
            environment = {
              ARM_UID = "1100";
              ARM_GID = "5500";
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
          "d ${armMediaDir} 0775 ${armUid} ${armGid} -"
          "d ${armMediaDir}/etc 0775 ${armUid} ${armGid} -"
          "d ${armMediaDir}/home 0775 ${armUid} ${armGid} -"
          "Z ${armMediaDir} 0775 ${armUid} ${armGid} -"
        ];
      };
      services = {
        "podman-arm" = {
          preStart = ''
            ${pkgs.coreutils}/bin/chown -R ${armUid}:${armGid} ${armMediaDir}
            ${pkgs.coreutils}/bin/chmod -R 775 ${armMediaDir}
          '';
        };
      };
    };
    users = {
      users = {
        cato = {
          extraGroups = ["cdrom" "video" "media"];
        };
      };
      groups = {
        arm-media = {
          gid = lib.toInt armGid;
        };
      };
    };
  };
}
