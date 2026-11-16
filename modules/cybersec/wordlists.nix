{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.wordlists.enable {
    environment = {
      systemPackages = with pkgs; [
        wordlists
        seclists
      ];
    };
  };
  options = {
    xanterella = {
      wordlists = {
        enable = lib.mkEnableOption "Aktiviert wordlists";
      };
    };
  };
}