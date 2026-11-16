{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      bash = {
        enable = true;
      };
      btop = {
        enable = true;
      };
      geistmono = {
        enable = true;
      };
      kitty = {
        enable = true;
      };
      local = {
        enable = true;
      };
      network-installer = {
        enable = true;
      };
      ssh-installer = {
        enable = true;
      };
      tailscale-installer = {
        enable = true;
      };
    };
  };
}