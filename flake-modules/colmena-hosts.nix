{
  inputs,
  systemarch,
  taruser,
  commonSSHKeys,
  pkgs-new,
  pkgs-unstable,
  pkgs-bleeding,
  ...
}: {
  meta = {
    nixpkgs = import inputs.nixpkgs {
      system = systemarch;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "docker-28.5.2"
        ];
      };
      purity = "impure";
    };
    nodeNixpkgs = {
      vicuna = import inputs.nixpkgs {
        system = "aarch64-linux";
        config = {
          allowUnfree = true;
        };
      };
    };
    specialArgs = {
      inputs = inputs;
      pkgs-new = pkgs-new;
      pkgs-unstable = pkgs-unstable;
      pkgs-bleeding = pkgs-bleeding;
    };
  };
  xeravus = {
    deployment = {
      targetHost = null;
      allowLocalDeployment = true;
      buildOnTarget = true;
    };
    imports = [
      ./../hosts/xeravus/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
  beta = {
    deployment = {
      targetHost = "beta";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      ./../hosts/beta/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
  omega = {
    deployment = {
      targetHost = "omega";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      ./../hosts/xorus/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
  alpha = {
    deployment = {
      targetHost = "alpha";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      ./../hosts/alpha/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
}
