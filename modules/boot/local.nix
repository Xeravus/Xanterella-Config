{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    xanterella = {
      local = {
        enable = lib.mkEnableOption "Aktiviert local";
      };
    };
  };

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
    time = {
      timeZone = "Europe/Berlin";
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
    console = {
      keyMap = "de";
    };
    users = {
      mutableUsers = false;
      users = {
        cato = {
          isNormalUser = true;
          description = "Cato";
          extraGroups = [
            "networkmanager"
            "wheel"
            "plugdev"
          ];
          hashedPasswordFile = config.age.secrets.password_cato.path;
        };
        root = {
          hashedPasswordFile = config.age.secrets.password_root.path;
        };
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
  };
}
