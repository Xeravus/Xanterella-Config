{
  config,
  pkgs-new,
  lib,
  inputs,
  ...
}: {
  config = lib.mkMerge [
    (lib.mkIf config.xanterella.browser.zen.enable {
      environment = {
        systemPackages = with pkgs-new; [
          inputs.zen-browser.packages.${pkgs.system}.default
        ];
      };
    })
    (lib.mkIf config.xanterella.browser.firefox.enable {
      environment = {
        systemPackages = with pkgs-new; [
          firefox
        ];
      };
      programs = {
        firefox = {
          enable = true;
        };
      };
    })
    (lib.mkIf config.xanterella.browser.librewolf.enable {
      environment = {
        systemPackages = with pkgs-new; [
          librewolf
        ];
      };
    })
  ];
  options = {
    xanterella = {
      browser = {
        firefox = {
          enable = lib.mkEnableOption "Aktiviert Firefox";
        };
        librewolf = {
          enable = lib.mkEnableOption "Aktiviert Librewolf";
        };
        zen = {
          enable = lib.mkEnableOption "Aktiviert zen";
        };
      };
    };
  };
}