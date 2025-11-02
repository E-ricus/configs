{
  description = "Personal dev tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Package LaunchDarkly CLI from binary release
        ldcli = pkgs.stdenv.mkDerivation rec {
          pname = "ldcli";
          # TODO: Automate for any sytem
          version = "2.0.1_linux_amd64"; # Check for latest version

          src = pkgs.fetchurl {
            url = "https://github.com/launchdarkly/ldcli/releases/download/v${version}/ldcli_${version}.tar.gz";
            # Will fail if the sha is different, just copy the correct one here
            sha256 = "sha256-/8NAKy0FBPbKJCSpLYRcSuoCRaOtVNzaverx3+oFxEY=";
          };

          nativeBuildInputs = [pkgs.autoPatchelfHook];
          buildInputs = [pkgs.stdenv.cc.cc.lib];
          sourceRoot = ".";

          installPhase = ''
            mkdir -p $out/bin
            cp ldcli $out/bin/
            chmod +x $out/bin/ldcli
          '';
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
