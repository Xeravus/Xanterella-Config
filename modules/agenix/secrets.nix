let
  cato = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc0eOrLgxwDdvrFC9WEtOsh+Sx5AqZUUKxhrQWaPIPE cato.jenisch@gmail.com";
  users = [
    cato
  ];

  xeravus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzkvv1qjg8y//HRhcyEoZ7luoVhBNgqvJ1HIzceAVu1";
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxZS/IOSqNcBYlg1oCDUIzqURCiNoQTmdXXQKcSfMpY";
  beta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKI1mJ/Bawht6CD7Z745X8oOD4vD0xJy+y8bNSZda5x";
  omega = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRuBimJgERluZGC7Jo1cd/DODfgiFJ6C8ScosEfgLEk";
  systems = [
    xeravus
    alpha
    omega
    beta
  ];
  server = [
    alpha
    beta
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
  "arcane-token-alpha.env.age" = {
    publicKeys = users ++ server;
  };
  "arcane-token-beta.env.age" = {
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
