{
  description = "Odin development environment with raylib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          odin
          ols
          raylib
        ];

        shellHook = ''
          export LD_LIBRARY_PATH="${pkgs.raylib}/lib:$LD_LIBRARY_PATH"
          echo "Odin + Raylib development environment loaded"
          echo "Raylib version: ${pkgs.raylib.version}"
        '';
      };
    });
}
