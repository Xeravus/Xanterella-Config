{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.xanterella.vscode.enable {
    environment = {
      systemPackages = with pkgs; [
        vscode
      ];
    };
  };
  options = {
    xanterella = {
      vscode = {
        enable = lib.mkEnableOption "Aktiviert vscode";
      };
    };
  };
}