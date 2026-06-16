{
  description = "C3 development environment with raylib's dependencies";

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
      c3c = pkgs.c3c.overrideAttrs (old: {
        version = "0.8.1";
        src = pkgs.fetchFromGitHub {
          owner = "c3lang";
          repo = "c3c";
          tag = "v0.8.1";
          hash = "sha256-HPPeedpbEgG6Zx6a+eV8CBO3rxMXMstLa4kx2NkNYnM=";
        };
      });
      # Main not working correctly yet.
      c3lsp = pkgs.buildGoModule {
        pname = "c3lsp";
        version = "0.5.0-dev";
        src = pkgs.fetchFromGitHub {
          owner = "pherrymason";
          repo = "c3-lsp";
          rev = "7a2b452662f708e21b0a1a19cc31475b97560a33";
          hash = "sha256-LRVrA5zlnNP9xmfoDGC4O5dIjBv23jW2thnHV4XlZ8I=";
        };
        sourceRoot = "source/server";
        vendorHash = "sha256-hOnY4gcnVeB5HcJja5WPK7vH2YJwxB3JkbHKJ5KQOg4=";
        postInstall = ''
          mv $out/bin/lsp $out/bin/c3lsp
        '';
      };
      tools = [c3c pkgs.c3-lsp];
      raylibDeps = with pkgs; [
        libGL
        libx11
        libxrandr
        libXinerama
        libxcursor
        libxxf86vm
        libXi
      ];
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = tools ++ raylibDeps;

        shellHook = ''
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath raylibDeps}:$LD_LIBRARY_PATH"

          cat > c3lsp.json << EOF
          {
            "C3": {
              "version": "${c3c.version}",
              "path": "${c3c}/bin/c3c",
              "stdlib-path": "${c3c}/lib/c3"
            },
            "Diagnostics": {
              "enabled": true,
              "delay": 100
            }
          }
          EOF

          echo "C3 with x11 libs loaded for raylib"
        '';
      };
    });
}
