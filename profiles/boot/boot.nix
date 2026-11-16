{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      agenix = {
        enable = true;
      };
      boot = {
        enable = true;
      };
      colmena = {
        enable = true;
      };
      git = {
        enable = true;
      };
      local = {
        enable = true;
      };
      network = {
        enable = true;
      };
      nix = {
        enable = true;
      };
      nixvim = {
        enable = true;
      };
      remote-install = {
        enable = true;
      };
      ssh = {
        enable = lib.mkForce true;
      };
    };
  };
}