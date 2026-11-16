{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.local.enable {
    age = {
      secrets = {
        password_cato = {
          file = ./../agenix/password_cato.age;
        };
        password_root = {
          file = ./../agenix/password_root.age;
        };
      };
    };
    console = {
      keyMap = "de";
    };
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
    };
    services = {
      xserver = {
        enable = true;
        xkb = {
          layout = "de";
          variant = "";
        };
      };
    };
    time = {
      timeZone = "Europe/Berlin";
    };
    users = {
      mutableUsers = false;
      users = {
        cato = {
          description = "Cato";
          extraGroups = [
            "networkmanager"
            "wheel"
            "plugdev"
          ];
          hashedPasswordFile = config.age.secrets.password_cato.path;
          isNormalUser = true;
        };
        root = {
          hashedPasswordFile = config.age.secrets.password_root.path;
        };
      };
    };
  };
  options = {
    xanterella = {
      local = {
        enable = lib.mkEnableOption "Aktiviert local";
      };
    };
  };
}