# Container tools — Podman.
{...}: {
  den.aspects.containers = {
    homeManager = {pkgs, config, ...}: {
      home.packages = [pkgs.podman-compose];

      # Symlink podman auth to where Docker Compose (used by arion) expects it.
      # Podman stores credentials at /run/user/<uid>/containers/auth.json,
      # but docker-compose reads ~/.docker/config.json.
      home.file.".docker/config.json".source =
        config.lib.file.mkOutOfStoreSymlink "/run/user/1000/containers/auth.json";
    };

    nixos = {...}: {
      virtualisation = {
        containers.registries.search = [
          "docker.io"
          "quay.io"
        ];
        podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
        };
      };
    };
  };
}
