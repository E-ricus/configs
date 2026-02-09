{
  description = "Personal dev tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Package LaunchDarkly CLI - building from source
        ldcli = pkgs.buildGoModule rec {
          pname = "ldcli";
          version = "2.0.1";

          src = pkgs.fetchFromGitHub {
            owner = "launchdarkly";
            repo = "ldcli";
            rev = "v${version}";
            sha256 = "sha256-1L1/nhd8wpnH38E0oSAzyS8G9wSQHD17xS29x46mSso=";
          };

          vendorHash = "sha256-oq2qH4wUR4/6e8S/e6nxDYVYpILNQGrPL1pxjgs8Kuo=";
        };

        # Define package sets for reuse
        personalPackages = with pkgs; [
          podman
          podman-compose
          podman-tui
        ];

        workPackages =
          personalPackages
          ++ [
            pkgs.awscli2
            pkgs.gh
            ldcli
          ];
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = personalPackages;
          };

          work = pkgs.mkShell {
            packages = workPackages;
          };
        };
      }
    );
}
