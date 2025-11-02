{
  description = "Home manager configuration for e-ric";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    walker,
    ...
  }: let
    # Define supported systems
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    # Helper to generate an attribute set for all systems
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Generate pkgs for each system
    pkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in {
    homeConfigurations = {
      "ericus" = home-manager.lib.homeManagerConfiguration {
        # Dynamically select pkgs based on current system, fallback to x86_64-linux
        pkgs = pkgsFor.${builtins.currentSystem or "x86_64-linux"};
        extraSpecialArgs = {inherit nixpkgs walker;};
        modules = [
          ./homes/linux.nix
        ];
      };
      "ericpuentes" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor."aarch64-darwin";
        extraSpecialArgs = {inherit nixpkgs;};
        modules = [
          ./homes/mac.nix
        ];
      };
    };
  };
}
