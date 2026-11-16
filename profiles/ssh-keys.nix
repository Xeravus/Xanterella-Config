{
  lib,
  ...
}: {
  users = {
    users = {
      cato = {
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc0eOrLgxwDdvrFC9WEtOsh+Sx5AqZUUKxhrQWaPIPE cato.jenisch@gmail.com"
            ];
          };
        };
      };
      root = {
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgfMNgJCAwI2rW1tcd9OkRZggyN5OfoZC7UDbIuEITT xanterella-root-key"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHc0eOrLgxwDdvrFC9WEtOsh+Sx5AqZUUKxhrQWaPIPE cato.jenisch@gmail.com"
            ];
          };
        };
      };
    };
  };
}