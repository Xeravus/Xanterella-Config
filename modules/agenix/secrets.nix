let
  cato = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc0eOrLgxwDdvrFC9WEtOsh+Sx5AqZUUKxhrQWaPIPE cato.jenisch@gmail.com";
  users = [
    cato
  ];

  xeravus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzkvv1qjg8y//HRhcyEoZ7luoVhBNgqvJ1HIzceAVu1";
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxZS/IOSqNcBYlg1oCDUIzqURCiNoQTmdXXQKcSfMpY";
  beta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKI1mJ/Bawht6CD7Z745X8oOD4vD0xJy+y8bNSZda5x";
  delta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbc635N+PoqYUcqG8sMxstYlMA3e3oY3YKm9Xb9w5jZ";
  epsilon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYRML/ER6FVA94fQNtioIKOpq4OX3Ewu/Y1DJcNfC1F";
  zeta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0yQPa0pLkli9ff1ryMRwFKGdOVpSVI1RraSxHPWhjA";
  omega = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRuBimJgERluZGC7Jo1cd/DODfgiFJ6C8ScosEfgLEk";
  systems = [
    xeravus
    alpha
    beta
    delta
    epsilon
    zeta
    omega
  ];
  server = [
    alpha
    beta
    delta
    epsilon
    zeta
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
  "minecraft-rcone.age" = {
    publicKeys = users ++ server;
  };
  "matrix.yaml.age" = {
    publicKeys = users ++ server;
  };
  "netbird.env.age" = {
    publicKeys = users ++ systems;
  };
  "paperless-pass.age" = {
    publicKeys = users ++ systems;
  };
  "s3.env.age" = {
    publicKeys = users ++ server;
  };
  "immich.env.age" = {
    publicKeys = users ++ systems;
  };
  "immich-api-key.age" = {
    publicKeys = users ++ server;
  };
  "yt-cookie.txt.age" = {
    publicKeys = users ++ server;
  };
  "github-runner.age" = {
    publicKeys = users ++ systems;
  };
}
