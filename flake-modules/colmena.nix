{
  inputs,
  withSystem,
  ...
}: let
  commonSSHKeys = {
    "github_key" = {
      destDir = "/root/.ssh";
      keyFile = "/home/cato/.ssh/id_github";
      permissions = "0600";
      user = "root";
    };
    "id_ed25519" = {
      destDir = "/etc/ssh";
      group = "root";
      keyFile = "/home/cato/.ssh/id_ed25519";
      permissions = "0600";
      user = "root";
    };
  };
  systemarch = "x86_64-linux";
  taruser = "root";
in {
    flake = rec {
      colmena = withSystem systemarch ({
        pkgs-new,
        pkgs-unstable,
        pkgs-bleeding,
        ...
      }: import ./colmena-hosts.nix {
        commonSSHKeys = commonSSHKeys;
        inputs = inputs;
        pkgs-bleeding = pkgs-bleeding;
        pkgs-new = pkgs-new;
        pkgs-unstable = pkgs-unstable;
        systemarch = systemarch;
        taruser = taruser;
      });
      colmenaHive = inputs.colmena.lib.makeHive colmena;
    };
  }