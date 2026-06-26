# lspmux package. Upstream: https://codeberg.org/p2502/lspmux
{
  lib,
  rustPlatform,
  fetchzip,
}: let
  rev = "18861f9d59e74ece8d867772cf07fa302c2dae98";
in
  rustPlatform.buildRustPackage {
    pname = "lspmux";
    version = "0.3.0-unstable-2026-03-11";

    src = fetchzip {
      url = "https://codeberg.org/p2502/lspmux/archive/${rev}.tar.gz";
      hash = "sha256-OchqUe8GdBPL6tE3zpdaThfhzYZhYluagz1yXiexFT0=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    meta = {
      description = "LSP multiplexer — share language servers between editor instances";
      homepage = "https://codeberg.org/p2502/lspmux";
      license = lib.licenses.eupl12;
      mainProgram = "lspmux";
    };
  }
