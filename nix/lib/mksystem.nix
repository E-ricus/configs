{inputs}: {
  system,
  hostname,
  user,
  hardwareConfig ? null,
  darwin ? false,
}: let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # Select appropriate home-manager module
  home-manager-module =
    if darwin
    then inputs.home-manager.darwinModules.home-manager
    else inputs.home-manager.nixosModules.home-manager;

  # Select appropriate system builder
  systemFunc =
    if darwin
    then inputs.nix-darwin.lib.darwinSystem
    else inputs.nixpkgs.lib.nixosSystem;

  # Platform-specific config path
  systemConfig =
    if darwin
    then ../systems/darwin/${hostname}/configuration.nix
    else
      ../systems/nixos/${
        if system == "x86_64-linux"
        then "x86_64"
        else "aarch64"
      }/configuration.nix;

  # Home-manager config based on user
  homeConfig =
    if user == "ericus"
    then ../home/linux.nix
    else ../home/mac.nix;
in
  systemFunc {
    inherit system;

    specialArgs = {
      inherit inputs hostname user;
    };

    modules = [
      systemConfig

      # Add hardware config for NixOS
      (
        if hardwareConfig != null
        then hardwareConfig
        else {}
      )

      # Integrate home-manager
      home-manager-module
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = import homeConfig;
        home-manager.extraSpecialArgs = {
          inherit inputs;
          walker = inputs.walker or null;
        };
      }
    ];
  }
