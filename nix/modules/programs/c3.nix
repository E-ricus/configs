# C3 language toolchain — compiler (pinned), LSP, and formatter.
#
# - Pins `c3c` to v0.8.0_3.
{...}: {
  den.aspects.c3 = {
    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: let
      # Override c3c to 0.8.0_3 (same override as nix/devshells/c3.nix).
      c3c = pkgs.c3c.overrideAttrs (_old: {
        version = "0.8.0_3";
        src = pkgs.fetchFromGitHub {
          owner = "c3lang";
          repo = "c3c";
          tag = "v0.8.0_3";
          hash = "sha256-7RqRnExQNnB4eM2LSLWdvHrDA7tJbiF6pzKGPRDgqHs=";
        };
      });

      # c3fmt — a C3 source code formatter.
      # Upstream: https://github.com/lmichaudel/c3fmt
      c3fmt = pkgs.stdenvNoCC.mkDerivation {
        pname = "c3fmt";
        version = "0.2.5";

        src = pkgs.fetchurl {
          url = "https://github.com/lmichaudel/c3fmt/releases/download/v0.2.5/c3fmt-linux";
          hash = "sha256-99XP31KWEyQpdxzzQbWuzFLkPEyamoFNKFc2LTg21P4=";
        };

        # The downloaded file is the bare ELF (not an archive).
        dontUnpack = true;

        # Dynamically-linked against glibc; relink against the nixpkgs one.
        nativeBuildInputs = [pkgs.autoPatchelfHook];
        buildInputs = [pkgs.stdenv.cc.cc.lib];

        installPhase = ''
          runHook preInstall
          install -Dm755 "$src" "$out/bin/c3fmt"
          runHook postInstall
        '';

        meta = {
          description = "A customizable code formatter for the C3 language";
          homepage = "https://github.com/lmichaudel/c3fmt";
          license = lib.licenses.mit;
          mainProgram = "c3fmt";
          platforms = ["x86_64-linux"];
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
      };
    in {
      home.packages = [c3c c3fmt pkgs.c3-lsp];

      # Symlink the c3 stdlib (and other c3c library data) into
      # $XDG_DATA_HOME/c3/lib so external tools (editors, language servers
      # configured outside of nix) can locate it at a predictable path.
      # The link target updates automatically when the c3c derivation
      # changes.
      xdg.dataFile."c3/lib".source = "${c3c}/lib";

      # Expose the same path via an env var for tools/scripts that prefer it.
      home.sessionVariables.C3_STDLIB_PATH = "${config.xdg.dataHome}/c3/lib";
    };
  };
}
