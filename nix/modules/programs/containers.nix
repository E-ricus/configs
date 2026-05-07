# Container tools — Podman.
{...}: {
  den.aspects.containers = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.podman-compose];
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
