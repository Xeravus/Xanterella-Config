{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      tailscale-installer = {
        enable = true;
      };
      network-installer = {
        enable = true;
      };
      ssh-installer = {
        enable = true;
      };
      local = {
        enable = true;
      };
      geistmono = {
        enable = true;
      };
      kitty = {
        enable = true;
      };
      zsh = {
        enable = true;
      };
      btop = {
        enable = true;
      };
    };
  };
}
