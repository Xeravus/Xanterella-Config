let
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxZS/IOSqNcBYlg1oCDUIzqURCiNoQTmdXXQKcSfMpY";
  beta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKI1mJ/Bawht6CD7Z745X8oOD4vD0xJy+y8bNSZda5x";
  cato = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc0eOrLgxwDdvrFC9WEtOsh+Sx5AqZUUKxhrQWaPIPE cato.jenisch@gmail.com";
  delta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLcip/nVOcM8SremGgyy1zF7bUzRzbdhL8oCjGUGz/1";
  epsilon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYRML/ER6FVA94fQNtioIKOpq4OX3Ewu/Y1DJcNfC1F";
  omega = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRuBimJgERluZGC7Jo1cd/DODfgiFJ6C8ScosEfgLEk";
  server = [
    alpha
    beta
    delta
    epsilon
    zeta
    xeravus
  ];
  systems = [
    xeravus
    alpha
    beta
    delta
    epsilon
    zeta
    omega
  ];
  users = [
    cato
  ];
  xeravus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzkvv1qjg8y//HRhcyEoZ7luoVhBNgqvJ1HIzceAVu1";
  zeta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH0yQPa0pLkli9ff1ryMRwFKGdOVpSVI1RraSxHPWhjA";
in {
    "arcane-token-alpha.env.age" = {
      publicKeys = users ++ server;
    };
    "arcane-token-beta.env.age" = {
      publicKeys = users ++ server;
    };
    "cloudflare-token.age" = {
      publicKeys = users ++ server;
    };
    "couchdb.env.age" = {
      publicKeys = users ++ server;
    };
    "github-runner.age" = {
      publicKeys = users ++ systems;
    };
    "global.age" = {
      publicKeys = users ++ systems;
    };
    "immich-api-key.age" = {
      publicKeys = users ++ server;
    };
    "immich.env.age" = {
      publicKeys = users ++ systems;
    };
    "matrix.yaml.age" = {
      publicKeys = users ++ server;
    };
    "minecraft-rcone.age" = {
      publicKeys = users ++ server;
    };
    "netbird.env.age" = {
      publicKeys = users ++ systems;
    };
    "paperless-pass.age" = {
      publicKeys = users ++ systems;
    };
    "password_cato.age" = {
      publicKeys = users ++ systems;
    };
    "password_root.age" = {
      publicKeys = users ++ systems;
    };
    "rclone.conf.age" = {
      publicKeys = users ++ server;
    };
    "s3.env.age" = {
      publicKeys = users ++ server;
    };
    "yt-cookie.txt.age" = {
      publicKeys = users ++ server;
    };
  }