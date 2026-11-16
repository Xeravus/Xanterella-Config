{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.xanterella.paperlessngx;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          paperless-pass = {
            file = ./../agenix/paperless-pass.age;
            owner = "paperless";
          };
        };
      };
      services = {
        paperless = {
          address = "0.0.0.0";
          consumptionDir = "/mnt/server-data/paperlessngx/consume";
          dataDir = "/mnt/server-data/paperlessngx";
          enable = true;
          mediaDir = "/mnt/server-data/paperlessngx/media";
          passwordFile = config.age.secrets.paperless-pass.path;
          port = 2731;
          settings = {
            PAPERLESS_ADMIN_USER = "admin";
            PAPERLESS_OCR_LANGUAGE = "deu+eng";
            PAPERLESS_TASK_WORKERS = 1;
            PAPERLESS_THREADS_PER_WORKER = 2;
            PAPERLESS_TIME_ZONE = "Europe/Berlin";
            PAPERLESS_URL = "https://${cfg.domain}";
          };
        };
      };
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/paperlessngx 0750 paperless paperless -"
            "d /mnt/server-data/paperlessngx/media 0750 paperless paperless -"
            "d /mnt/server-data/paperlessngx/consume 0770 paperless paperless -"
          ];
        };
      };
    };
    options = {
      xanterella = {
        paperlessngx = {
          domain = lib.mkOption {
            default = "${nodeCfg.domain}:1007";
            type = lib.types.str;
          };
          enable = lib.mkEnableOption "Aktiviert paperlessngx";
        };
      };
    };
  }