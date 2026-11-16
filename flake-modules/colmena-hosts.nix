{
  inputs,
  systemarch,
  taruser,
  commonSSHKeys,
  pkgs-new,
  pkgs-unstable,
  pkgs-unstable,
  ...
}: {
  meta = {
    nixpkgs = import inputs.nixpkgs {
      system = systemarch;
      config = {
        allowUnfree = true;
      };
      purity = "impure";
    };
    specialArgs = {
      inputs = inputs;
      pkgs-new = pkgs-new;
      pkgs-unstable = pkgs-unstable;
      pkgs-bleeding = pkgs-bleeding;
    };
  };
  alpha = {
    deployment = {
      targetHost = "alpha";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      inputs.disko.nixosModules.disko
      ./../hosts/alpha/configuration.nix
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
      inputs.disko.nixosModules.disko
      ./../hosts/beta/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
  delta = {
    deployment = {
      targetHost = "delta";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      inputs.disko.nixosModules.disko
      ./../hosts/delta/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
  epsilon = {
    deployment = {
      targetHost = "epsilon";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      inputs.disko.nixosModules.disko
      ./../hosts/epsilon/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
  installer = {
    deployment = {
      targetHost = "installer";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      ./../hosts/installer/configuration.nix
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
  xeravus = {
    deployment = {
      targetHost = null;
      allowLocalDeployment = true;
      buildOnTarget = true;
    };
    imports = [
      inputs.disko.nixosModules.disko
      ./../hosts/xeravus/configuration.nix
    ];
  };
  zeta = {
    deployment = {
      targetHost = "zeta";
      targetUser = taruser;
      buildOnTarget = false;
      keys = commonSSHKeys;
    };
    imports = [
      inputs.disko.nixosModules.disko
      ./../hosts/zeta/configuration.nix
      ./../profiles/ssh-keys.nix
    ];
  };
}