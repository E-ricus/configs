# C3 language toolchain.
#
{...}: {
  flake.modules.homeManager.c3 = {
    pkgs,
    lib,
    config,
    ...
  }: let
    # c3fmt — a C3 source code formatter.
    # Upstream: https://github.com/lmichaudel/c3fmt
    c3fmt = pkgs.stdenvNoCC.mkDerivation {
      pname = "c3fmt";
      version = "0.3.5";

      src = pkgs.fetchurl {
        url = "https://github.com/lmichaudel/c3fmt/releases/download/v0.3.5/c3fmt-linux";
        hash = "sha256-im/7Vy5L4d7/dbnXDkVbLqHpBC1rkCHuwTbRDz/quxg=";
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
    home.packages = [pkgs.c3c c3fmt pkgs.c3-lsp];

    # Symlink the c3 stdlib (and other c3c library data) into
    # $XDG_DATA_HOME/c3/lib so external tools (editors, language servers
    # configured outside of nix) can locate it at a predictable path.
    # The link target updates automatically when the c3c derivation
    # changes.
    xdg.dataFile."c3/lib".source = "${pkgs.c3c}/lib";

    # Expose the same path via an env var for tools/scripts that prefer it.
    home.sessionVariables.C3_STDLIB_PATH = "${config.xdg.dataHome}/c3/lib";
  };
}
