{
  inputs,
  withSystem,
  ...
}: {
  perSystem = {system, ...}: {
    _module.args = {
      pkgs-new = import inputs.nixpkgs-new {
        system = system;
        config = {
          allowUnfree = true;
        };
      };
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "olm-3.2.16"
          ];
        };
      };
      pkgs-bleeding = import inputs.nixpkgs-bleeding-edge {
        system = system;
        config = {
          allowUnfree = true;
        };
      };
    };
  };
  flake = {
    nixosConfigurations = {
      xeravus = withSystem "x86_64-linux" ({
        pkgs-new,
        pkgs-unstable,
        pkgs-bleeding,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inputs = inputs;
            pkgs-new = pkgs-new;
            pkgs-unstable = pkgs-unstable;
            pkgs-bleeding = pkgs-bleeding;
          };
          modules = [
            inputs.disko.nixosModules.disko
            ./../hosts/xeravus/configuration.nix
          ];
        });
      swetik = withSystem "x86_64-linux" ({
        pkgs-new,
        pkgs-unstable,
        pkgs-bleeding,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inputs = inputs;
            pkgs-new = pkgs-new;
            pkgs-unstable = pkgs-unstable;
            pkgs-bleeding = pkgs-bleeding;
          };
          modules = [
            inputs.disko.nixosModules.disko
            ./../hosts/swetik/configuration.nix
          ];
        });
      xorus = withSystem "x86_64-linux" ({
        pkgs-new,
        pkgs-unstable,
        pkgs-bleeding,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inputs = inputs;
            pkgs-new = pkgs-new;
            pkgs-unstable = pkgs-unstable;
            pkgs-bleeding = pkgs-bleeding;
          };
          modules = [
            inputs.disko.nixosModules.disko
            ./../hosts/xorus/configuration.nix
          ];
        });
      installer = withSystem "x86_64-linux" ({
        pkgs-new,
        pkgs-unstable,
        pkgs-bleeding,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inputs = inputs;
            pkgs-new = pkgs-new;
            pkgs-unstable = pkgs-unstable;
            pkgs-bleeding = pkgs-bleeding;
          };
          modules = [
            ./../hosts/installer/configuration.nix
            ./../profiles/ssh-keys.nix
          ];
        });
      vicuna-image = withSystem "aarch64-linux" ({
        pkgs-new,
        pkgs-unstable,
        pkgs-bleeding,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inputs = inputs;
            pkgs-new = pkgs-new;
            pkgs-unstable = pkgs-unstable;
            pkgs-bleeding = pkgs-bleeding;
          };
          modules = [
            ./../hosts/vicuna/configuration.nix
            ./../profiles/ssh-keys.nix
            inputs.nixos-hardware.nixosModules.raspberry-pi-5
            "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];
        });
      crylia = withSystem "x86_64-linux" ({
        pkgs-new,
        pkgs-unstable,
        pkgs-bleeding,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inputs = inputs;
            pkgs-new = pkgs-new;
            pkgs-unstable = pkgs-unstable;
            pkgs-bleeding = pkgs-bleeding;
          };
          modules = [
            ./../hosts/crylia/configuration.nix
            ./../profiles/ssh-keys.nix
          ];
        });
    };
  };
}
