{
  config,
  pkgs,
  lib,
  ...
}: let
  secrets = import "/home/cato/xanterella/config/modules/agenix/usb-secrets.nix";
in {
    config = lib.mkMerge [
      (lib.mkIf config.xanterella.network.enable {
        networking = {
          networkmanager = {
            enable = true;
            insertNameservers = [
              "1.1.1.1"
              "1.0.0.1"
              "8.8.8.8"
            ];
          };
          wireless = {
            enable = false;
          };
        };
      })
      (lib.mkIf config.xanterella.network-crylia.enable {
        networking = {
          networkmanager = {
            enable = true;
            ensureProfiles = {
              environmentFiles = [
                "/etc/wifi_secrets"
              ];
              profiles = {
                home = {
                  connection = {
                    id = "Obi Wlan Kenobi";
                    type = "wifi";
                  };
                  ipv4 = {
                    method = "auto";
                  };
                  ipv6 = {
                    method = "auto";
                  };
                  wifi = {
                    mode = "infrastructure";
                    ssid = "Obi Wlan Kenobi";
                  };
                  wifi-security = {
                    auth-alg = "open";
                    key-mgmt = "wpa-psk";
                    psk = "$PSK_HOME";
                  };
                };
              };
            };
            insertNameservers = [
              "1.1.1.1"
              "1.0.0.1"
              "8.8.8.8"
            ];
          };
          wireless = {
            enable = false;
          };
        };
      })
      (lib.mkIf config.xanterella.network-installer.enable {
        networking = {
          networkmanager = {
            enable = true;
            ensureProfiles = {
              profiles = {
                "${secrets.wifiSsid}" = {
                  connection = {
                    id = secrets.wifiSsid;
                    type = "wifi";
                  };
                  ipv4 = {
                    method = "auto";
                  };
                  ipv6 = {
                    method = "auto";
                  };
                  wifi = {
                    mode = "infrastructure";
                    ssid = secrets.wifiSsid;
                  };
                  wifi-security = {
                    auth-alg = "open";
                    key-mgmt = "wpa-psk";
                    psk = secrets.wifiPassword;
                  };
                };
              };
            };
          };
          wireless = {
            enable = false;
          };
        };
      })
    ];
    options = {
      xanterella = {
        network = {
          enable = lib.mkEnableOption "Aktiviert network";
        };
        network-crylia = {
          enable = lib.mkEnableOption "Aktiviert NetworkManger für Crylia";
        };
        network-installer = {
          enable = lib.mkEnableOption "Aktiviert NetworkManager für den Installer mit automatischen Wlan Passwort";
        };
      };
    };
  }