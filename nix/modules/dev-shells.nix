{...}: {
  perSystem = {pkgs, ...}: let
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
  in {
    devShells = {
      odin = pkgs.mkShell {
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
      work = pkgs.mkShell {
        packages = [
          pkgs.awscli2
          pkgs.gh
          ldcli
        ];
      };
    };
  };
}
