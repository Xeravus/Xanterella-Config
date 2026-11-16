{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.audio.enable {
    environment = {
      systemPackages = with pkgs; [
        playerctl
        pavucontrol
        pipewire
      ];
    };
    services = {
      pipewire = {
        alsa = {
          enable = true;
          support32Bit = true;
        };
        enable = true;
        pulse = {
          enable = true;
        };
      };
    };
  };
  options = {
    xanterella = {
      audio = {
        enable = lib.mkEnableOption "Aktiviert playerctl, pipewire, pavucontrol";
      };
    };
  };
}