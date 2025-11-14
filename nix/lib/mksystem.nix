{inputs}: {
  system,
  hostname,
  user,
  darwin ? false,
  determinate ? false,
}: let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # Select appropriate home-manager module
  home-manager-module =
    if !darwin
    then inputs.home-manager.nixosModules.home-manager
    else inputs.home-manager.darwinModules.home-manager;

  # Select appropriate system builder
  systemFunc =
    if !darwin
    then inputs.nixpkgs.lib.nixosSystem
    else inputs.nix-darwin.lib.darwinSystem;

  # Platform-specific config path
  systemConfig =
    if !darwin
    then ../hosts/nixos/${hostname}/configuration.nix
    else ../hosts/darwin/${hostname}/configuration.nix;

  # Auto-construct hardware config path for NixOS (null for Darwin)
  hardwareConfig =
    if !darwin
    then ../hosts/nixos/${hostname}/hardware-configuration.nix
    else null;

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
      # Add hardware config for NixOS
      (
        if hardwareConfig != null
        then hardwareConfig
        else {}
      )

      systemConfig

      # Add dterminate system's nix
      (
        if determinate
        then inputs.determinate.nixosModules.default
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
