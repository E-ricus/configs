# Container tools — Podman.
{den, ...}: {
  den.aspects.containers = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.podman-compose];
      services.podman.enable = true;
    };
  };
}
