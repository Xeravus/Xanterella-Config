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
          makemkv = {
            image = "jlesage/makemkv";
            ports = ["0.0.0.0:5800:5800"];
            volumes = [
              "/mnt/server-data/makemkv/config:/config"
              "/mnt/server-data/makemkv/storage:/storage"
            ];
            devices = [
              "/dev/sr0:/dev/sr0"
              "/dev/sg0:/dev/sg0"
            ];
            extraOptions = [
              "--network=host"
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
          "d /mnt/server-data/makemkv 0775 root root -"
          "d /mnt/server-data/makemkv/config 0775 root root -"
          "d /mnt/server-data/makemkv/storage 0775 root root -"
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
