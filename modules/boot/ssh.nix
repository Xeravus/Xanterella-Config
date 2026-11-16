{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.ssh.enable {
      environment = {
        systemPackages = with pkgs; [
          openssh
          kitty.terminfo
        ];
      };
      programs = {
        ssh = {
          askPassword = lib.mkForce "";
          startAgent = true;
        };
      };
      services = {
        openssh = {
          authorizedKeysFiles = lib.mkForce [
            "/etc/ssh/authorized_keys.d/%u"
            ".ssh/authorized_keys"
          ];
          enable = true;
          settings = {
            PermitRootLogin = "prohibit-password";
            UseDns = true;
          };
          startWhenNeeded = true;
        };
      };
    })
    (lib.mkIf config.xanterella.ssh-installer.enable {
      programs = {
        ssh = {
          askPassword = lib.mkForce "";
        };
      };
      services = {
        openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
          };
        };
      };
    })
  ];
  options = {
    xanterella = {
      ssh = {
        enable = lib.mkEnableOption "Aktiviert ssh";
      };
      ssh-installer = {
        enable = lib.mkEnableOption "Aktiviert ssh für den Installer";
      };
    };
  };
}