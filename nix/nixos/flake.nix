{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    nixosConfigurations = {
      # x86_64 configuration
      nixos-x86 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./configuration.nix];
      };

      # aarch64 configuration
      nixos-arm = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [./configuration.nix];
      };
    };
  };
}
