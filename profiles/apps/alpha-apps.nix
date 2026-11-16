{
  config,
  lib,
  ...
}: {
  config = {
    xanterella = {
      attic-server = {
        enable = true;
      };
      audiobookshelf = {
        enable = true;
      };
      btop = {
        enable = true;
      };
      cluster-node = {
        domain = "xanterella.de";
        enable = true;
        head = true;
        tailscale-domain = "gute-nessie.ts.net";
      };
      fastfetch = {
        enable = true;
      };
      immich = {
        enable = true;
        ml-domain = "beta.gute-nessie.ts.net";
      };
      jellyfin-bucket = {
        enable = true;
      };
      livesync = {
        enable = true;
      };
      matrix-server = {
        enable = true;
      };
      monitoring = {
        enable = true;
      };
      opsbot = {
        enable = false;
      };
      prometheus = {
        enable = true;
      };
      vaultwarden = {
        enable = true;
      };
      vikunja = {
        enable = true;
      };
    };
  };
}