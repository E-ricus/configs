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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sqlit = {
      url = "github:Maxteabag/sqlit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    # Helper to create system configurations
    mkSystem = import ./lib/mksystem.nix {inherit inputs;};
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
  };
}
