# Container tools — Podman.
{config, ...}: {
  flake.modules.homeManager.containers = {
    pkgs,
    config,
    ...
  }: {
    home.packages = [pkgs.podman-compose];

    # Symlink podman auth to where Docker Compose expects it.
    # Podman stores credentials at /run/user/<uid>/containers/auth.json,
    # but docker-compose reads ~/.docker/config.json.
    home.file.".docker/config.json".source =
      config.lib.file.mkOutOfStoreSymlink "/run/user/1000/containers/auth.json";
  };

  flake.modules.nixos.containers = {...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager.containers];
    virtualisation = {
      containers.registries.settings.unqualified-search-registries = [
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
}
