{
  description = "Development shell for Mojo GPU Puzzles";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.pixi ];

        shellHook = ''
          driverLib=/run/opengl-driver/lib
          if [ -f "$driverLib/libcuda.so.1" ]; then
            export LD_LIBRARY_PATH="$driverLib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          fi
          unset driverLib
        '';
      };
    };
}
