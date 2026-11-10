{
  inputs,
  withSystem,
  ...
}: let
  systemarch = "x86_64-linux";
  taruser = "root";
  commonSSHKeys = {
    "id_ed25519" = {
      keyFile = "/home/cato/.ssh/id_ed25519";
      destDir = "/etc/ssh";
      user = "root";
      group = "root";
      permissions = "0600";
    };
    "github_key" = {
      keyFile = "/home/cato/.ssh/id_github";
      destDir = "/root/.ssh";
      user = "root";
      permissions = "0600";
    };
  };
in {
  flake = rec {
    colmena = withSystem systemarch ({
      pkgs-new,
      pkgs-unstable,
      pkgs-bleeding,
      ...
    }:
      import ./colmena-hosts.nix {
        inputs = inputs;
        systemarch = systemarch;
        taruser = taruser;
        commonSSHKeys = commonSSHKeys;
        pkgs-new = pkgs-new;
        pkgs-unstable = pkgs-unstable;
        pkgs-bleeding = pkgs-bleeding;
      });

    colmenaHive = inputs.colmena.lib.makeHive colmena;
  };
}
