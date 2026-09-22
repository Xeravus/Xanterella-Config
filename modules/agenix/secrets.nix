let
  cato = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc0eOrLgxwDdvrFC9WEtOsh+Sx5AqZUUKxhrQWaPIPE cato.jenisch@gmail.com";
  users = [
    cato
  ];

  xeravus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzkvv1qjg8y//HRhcyEoZ7luoVhBNgqvJ1HIzceAVu1";
  lutik = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxZS/IOSqNcBYlg1oCDUIzqURCiNoQTmdXXQKcSfMpY";
  swetik = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKI1mJ/Bawht6CD7Z745X8oOD4vD0xJy+y8bNSZda5x";
  xorus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRuBimJgERluZGC7Jo1cd/DODfgiFJ6C8ScosEfgLEk";
  systems = [
    xeravus
    lutik
    xorus
    swetik
  ];
  server = [
    lutik
    swetik
    xeravus
  ];
in {
  "global.age" = {
    publicKeys = users ++ systems;
  };
  "password_cato.age" = {
    publicKeys = users ++ systems;
  };
  "password_root.age" = {
    publicKeys = users ++ systems;
  };
  "cloudflare-token.age" = {
    publicKeys = users ++ server;
  };
  "couchdb.env.age" = {
    publicKeys = users ++ server;
  };
  "arcane-token-lutik.env.age" = {
    publicKeys = users ++ server;
  };
  "arcane-token-swetik.env.age" = {
    publicKeys = users ++ server;
  };
  "rclone.conf.age" = {
    publicKeys = users ++ server;
  };
  "matrix.yaml.age" = {
    publicKeys = users ++ server;
  };
  "mautrix_disord.env.age" = {
    publicKeys = users ++ server;
  };
  "mautrix_whatsapp.env.age" = {
    publicKeys = users ++ server;
  };
  "matrix-opsbot-token.age" = {
    publicKeys = users ++ server;
  };
  "netbird.env.age" = {
    publicKeys = users ++ systems;
  };
  "paperless-pass.age" = {
    publicKeys = users ++ systems;
  };
  "immich.env.age" = {
    publicKeys = users ++ systems;
  };
  "yt-cookie.txt.age" = {
    publicKeys = users ++ server;
  };
  "github-runner.age" = {
    publicKeys = users ++ systems;
  };
}
