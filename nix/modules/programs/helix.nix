# Helix editor — mattwparas' fork with the Steel (Scheme) plugin system.
#
# Upstream fork: https://github.com/mattwparas/helix/tree/steel-event-system
# Tracking PR:   https://github.com/helix-editor/helix/pull/8675
#
# IMPORTANT: STEEL_HOME must be WRITABLE. At every startup the steel-enabled `hx`
# generates its builtin `.scm` modules into `$STEEL_HOME/cogs/helix/`
# (create_dir_all + write, both unwrapped — a read-only path panics with
# "Read-only file system" at steel/mod.rs:1354). The steel repl likewise writes
# `$STEEL_HOME/history`. So we CANNOT point STEEL_HOME at the read-only nix store.
# Instead we use a writable dir in $HOME and seed it with the store cogs on each
# activation — exactly what `cargo xtask steel` does when it populates ~/.steel.
#
# The scheme config itself lives in ~/.config/helix (init.scm, helix.scm, cogs/)
# and is symlinked from configs/helix via symlinkmanager.
{
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # The fork's flake exposes `packages.<system>.helix` (steel feature OFF by
    # default). Turn on `steel` + `git` to match `cargo xtask steel`.
    packages.helix-steel =
      inputs.helix-steel.packages.${system}.helix.overrideAttrs (old: {
        buildFeatures = (old.buildFeatures or []) ++ ["steel" "git"];
      });
  };

  den.aspects.helix = {
    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: let
      helix-steel = self.packages.${pkgs.stdenv.hostPlatform.system}.helix-steel;
      # Writable steel home (~/.local/share/steel). See header comment for why
      # the read-only nix store path cannot be used.
      steelHome = "${config.xdg.dataHome}/steel";
    in {
      home.packages = [
        helix-steel
        # steel toolchain: `steel` (repl/interpreter), `forge` (package manager),
        # `steel-language-server`, `cargo-steel-lib`. Also ships the cogs stdlib.
        pkgs.steel
      ];

      # Steel (and the steel-enabled hx) resolve the standard library (cogs)
      # relative to STEEL_HOME, and also WRITE into it at runtime.
      home.sessionVariables.STEEL_HOME = steelHome;

      # Seed the writable STEEL_HOME with the steel stdlib cogs from the nix
      # store, mirroring `cargo xtask steel`. Idempotent, refreshes on rebuild.
      # --no-preserve restores write perms (store files are read-only); helix's
      # own generated cogs/helix/ stays intact (copy is additive per-file).
      home.activation.steelHome = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run mkdir -p ${lib.escapeShellArg steelHome}
        run cp -rf --no-preserve=mode,ownership \
          ${pkgs.steel}/lib/steel/. ${lib.escapeShellArg steelHome}/
        run chmod -R u+w ${lib.escapeShellArg steelHome}
      '';
    };
  };
}
