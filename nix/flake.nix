{
  description = "E-ric's nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

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
    determinate,
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
      laptop-amd = mkSystem {
        system = "x86_64-linux";
        hostname = "laptop-amd";
        user = "ericus";
        determinate = true;
        modules = [
          ./modules
        ];
      };

      laptop-lenovo = mkSystem {
        system = "x86_64-linux";
        hostname = "laptop-lenovo";
        user = "ericus";
        determinate = true;
        modules = [
          ./modules
        ];
      };

      vm-aarch64 = mkSystem {
        system = "aarch64-linux";
        hostname = "vm-aarch64";
        user = "ericus";
        modules = [
          ./modules
        ];
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
    # Format: username-hostname
    homeConfigurations = {
      "ericus-laptop-amd" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor."x86_64-linux";
        extraSpecialArgs = {inherit inputs walker;};
        modules = [./hosts/nixos/laptop-amd/home.nix];
      };

      "ericus-laptop-lenovo" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor."x86_64-linux";
        extraSpecialArgs = {inherit inputs walker;};
        modules = [./hosts/nixos/laptop-lenovo/home.nix];
      };

      "ericus-vm-aarch64" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor."aarch64-linux";
        extraSpecialArgs = {inherit inputs walker;};
        modules = [./hosts/nixos/vm-aarch64/home.nix];
      };

      "ericpuentes-work-mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor."aarch64-darwin";
        extraSpecialArgs = {inherit inputs walker;};
        modules = [
          ./hosts/darwin/work-mac/home.nix
          # Override fish to skip tests on macOS due to regression (https://github.com/NixOS/nixpkgs/issues/461406)
          # TODO: Remove this when the fish regression is fixed
          {
            nixpkgs.overlays = [
              (final: prev: {
                fish = prev.fish.overrideAttrs (old: {
                  doCheck = false;
                });
              })
            ];
          }
        ];
      };
    };
  };
}
