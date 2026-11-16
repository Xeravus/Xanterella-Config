{
  config,
  pkgs-unstable,
  lib,
  inputs,
  ...
}: let
  cfg = config.xanterella.livesync;
  nodeCfg = config.xanterella.cluster-node;
in {
    config = lib.mkIf (cfg.enable && nodeCfg.enable) {
      age = {
        secrets = {
          couchdb-env = {
            file = ./../agenix/couchdb.env.age;
          };
        };
      };
      systemd = {
        tmpfiles = {
          rules = [
            "d /mnt/server-data/livesync 0755 root root -"
            "d /mnt/server-data/livesync/configs 0755 root root -"
            "d /mnt/server-data/livesync/icons 0755 root root -"
            "d /mnt/server-data/livesync/data 0755 root root -"
          ];
        };
      };
      virtualisation = {
        oci-containers = {
          containers = {
            obsidian-couchdb = {
              cmd = [
                "/bin/sh"
                "-c"
                "echo '[chttpd]\nenable_cors = true\n[cors]\norigins = app://obsidian.md,capacitor://localhost,http://localhost\ncredentials = true\nmethods = GET, PUT, POST, HEAD, DELETE\nheaders = accept, authorization, content-type, origin, referer, x-csrf-token' > /opt/couchdb/etc/local.d/cors.ini && /docker-entrypoint.sh /opt/couchdb/bin/couchdb"
              ];
              environmentFiles = [
                config.age.secrets.couchdb-env.path
              ];
              image = "couchdb:3";
              ports = [
                "0.0.0.0:5984:5984"
              ];
            };
          };
        };
      };
    };
    options = {
      xanterella = {
        livesync = {
          enable = lib.mkEnableOption "Aktiviert Livesync für Obsidian";
        };
      };
    };
  }