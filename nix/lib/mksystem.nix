# System builder helper function
# Creates unified NixOS or nix-darwin configurations with integrated home-manager
#
# Usage in flake.nix:
#   mkSystem = import ./lib/mksystem.nix {inherit inputs;};
#   nixosConfigurations.hostname = mkSystem {
#     system = "x86_64-linux";
#     hostname = "laptop-amd";
#     user = "ericus";
#     modules = [ ./modules ];
#   };
#
# Parameters:
#   system: Architecture (e.g., "x86_64-linux", "aarch64-darwin")
#   hostname: System hostname (used to locate config files)
#   user: Primary username for home-manager
#   darwin: Whether this is a macOS system (default: false)
#   determinate: Whether to use Determinate Systems' nix (default: false)
#   modules: Additional system modules to include (default: [])
#
# File structure expected:
#   hosts/<nixos|darwin>/<hostname>/configuration.nix  - System config
#   hosts/nixos/<hostname>/hardware-configuration.nix  - Hardware config (NixOS only)
#   hosts/<nixos|darwin>/<hostname>/home.nix           - Home-manager config
{inputs}: {
  system,
  hostname,
  user,
  darwin ? false,
  determinate ? false,
  modules ? [],
}: let
  # Import nixpkgs with unfree packages enabled
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # Select the appropriate home-manager module for the platform
  home-manager-module =
    if !darwin
    then inputs.home-manager.nixosModules.home-manager
    else inputs.home-manager.darwinModules.home-manager;

  # Select the appropriate system builder function
  systemFunc =
    if !darwin
    then inputs.nixpkgs.lib.nixosSystem
    else inputs.nix-darwin.lib.darwinSystem;

  # Platform-specific system configuration path
  systemConfig =
    if !darwin
    then ../hosts/nixos/${hostname}/configuration.nix
    else ../hosts/darwin/${hostname}/configuration.nix;

  # Hardware configuration (NixOS only, null for Darwin)
  hardwareConfig =
    if !darwin
    then ../hosts/nixos/${hostname}/hardware-configuration.nix
    else null;

  # Home-manager configuration for the user
  homeConfig =
    if !darwin
    then ../hosts/nixos/${hostname}/home.nix
    else ../hosts/darwin/${hostname}/home.nix;
in
  systemFunc {
    inherit system;

    # Make flake inputs available to all system modules
    # Access as: inputs.nixpkgs, inputs.home-manager, etc.
    specialArgs = {
      inherit inputs hostname user;
    };

    modules =
      [
        # Hardware configuration (NixOS only)
        (
          if hardwareConfig != null
          then hardwareConfig
          else {}
        )

        # Main system configuration
        systemConfig

        # Determinate Systems' nix (optional, NixOS only)
        (
          if determinate
          then inputs.determinate.nixosModules.default
          else {}
        )

        # Integrate home-manager into the system configuration
        home-manager-module
        {
          # Use the system's nixpkgs for home-manager packages
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          
          # Load the user's home configuration
          home-manager.users.${user} = import homeConfig;
          
          # Backup conflicting files instead of failing
          home-manager.backupFileExtension = "backup";
          
          # Make all flake inputs available to home-manager modules
          # Access them as: inputs.walker, inputs.noctalia, inputs.niri, etc.
          # The 'darwin' flag indicates whether this is a macOS system
          home-manager.extraSpecialArgs = {
            inherit inputs darwin;
          };
        }
      ]
      # Append any additional modules specified in flake.nix
      ++ modules;
  }
