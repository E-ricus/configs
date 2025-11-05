{
  description = "E-ric's nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom inputs
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    walker,
    ...
  } @ inputs: let
    # Helper to create system configurations
    mkSystem = import ./lib/mksystem.nix {inherit inputs;};

    # Define supported systems
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    # Helper to generate an attribute set for all systems
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Generate pkgs for each system with allowUnfree enabled
    pkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    # NixOS configurations
    nixosConfigurations = {
      nixos-x86 = mkSystem {
        system = "x86_64-linux";
        hostname = "nixos-x86";
        user = "ericus";
        hardwareConfig = ./systems/nixos/x86_64/hardware-configuration.nix;
      };

      nixos-arm = mkSystem {
        system = "aarch64-linux";
        hostname = "nixos-arm";
        user = "ericus";
        hardwareConfig = ./systems/nixos/aarch64/hardware-configuration.nix;
      };
    };

    # Darwin configurations
    darwinConfigurations = {
      work-mac = mkSystem {
        system = "aarch64-darwin";
        hostname = "work-mac";
        user = "ericpuentes";
        darwin = true;
      };
    };

    # Standalone home-manager configurations (for quick iteration)
    homeConfigurations = {
      "ericus" = home-manager.lib.homeManagerConfiguration {
        # Dynamically select pkgs based on current system, fallback to x86_64-linux
        pkgs = pkgsFor.${builtins.currentSystem or "x86_64-linux"};
        extraSpecialArgs = {inherit inputs walker;};
        modules = [./home/linux.nix];
      };

      "ericpuentes" = home-manager.lib.homeManagerConfiguration {
        # Dynamically select pkgs based on current system, fallback to aarch64-darwin
        pkgs = pkgsFor.${builtins.currentSystem or "aarch64-darwin"};
        extraSpecialArgs = {inherit inputs;};
        modules = [./home/mac.nix];
      };
    };
  };
}
