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
    linuxSystem = "x86_64-linux";
    macSystem = "aarch64-darwin";
  in {
    homeConfigurations = {
      "ericus" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${linuxSystem};
        extraSpecialArgs = {inherit nixpkgs walker;};
        modules = [
          ./homes/linux.nix
        ];
      };
      "ericpuentes" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${macSystem};
        extraSpecialArgs = {inherit nixpkgs;};
        modules = [
          ./homes/mac.nix
        ];
      };
    };
  };
}
