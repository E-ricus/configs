# LLM coding tools.
# opencode is wrapped with baked-in config. Run standalone: nix run .#opencode
# codex stays as a plain package (no wrapper module config needed yet).
#
# NOTE: The wrapper sets OPENCODE_CONFIG via envDefault (only if not already set).
# If ~/.config/opencode/opencode.jsonc exists, opencode reads it directly and
# the wrapper config acts as a fallback. To use ONLY the wrapped config,
# remove the local file. To override just secrets, keep the local file with
# only the secret values — opencode will read
# the local file first.
{self, inputs, ...}: {
  perSystem = {pkgs, system, ...}: let
    # WORKAROUND (2026-09-15): opencode has a circular import between
    # core/src/filesystem.ts and core/src/filesystem/search.ts that only works
    # under one particular module evaluation order. Bun 1.4.2's bundler emits
    # the two in the opposite order, leaving FileSystemSearch.node undefined in
    # a dependency array, and then EVERY prompt dies client-side with
    #   TypeError: undefined is not an object (evaluating 'a.name')
    #     at SystemPrompt.environment
    # surfacing in the TUI as "Failed to send prompt / Unexpected server error".
    # Upstream's own 1.18.30 binaries are fine because they ship built with bun
    # 1.3.x; nixpkgs builds from source and bumped bun on 2026-09-12, so the
    # breakage arrives via nixpkgs, not via an opencode release. 1.18.31 does
    # NOT contain the fix.
    #
    # Building with the older bun restores the working module order. Only the
    # bundler step changes: the node_modules FOD hash is bun-independent
    # (nixpkgs runs canonicalize-node-modules.ts / normalize-bun-binaries.ts),
    # so no hashes need overriding.
    #
    # Drop this, the `system` arg, and the nixpkgs-bun input once
    # anomalyco/opencode#48876 (PR #48877) lands and reaches nixpkgs.
    opencodePkg = pkgs.opencode.override {
      bun = inputs.nixpkgs-bun.legacyPackages.${system}.bun;
    };
  in {
    packages.opencode = inputs.wrapper-modules.wrappers.opencode.wrap {
      inherit pkgs;
      package = opencodePkg;
      settings = {
        theme = "catppuccin";
        mcp = {
          datadog = {
            type = "remote";
            enabled = true;
            oauth = {};
            url = "https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp";
          };
          Context7 = {
            type = "local";
            command = ["npx" "-y" "@upstash/context7-mcp"];
          };
          notion = {
            type = "remote";
            enabled = true;
            oauth = {};
            url = "https://mcp.notion.com/mcp";
          };
          linear = {
            type = "remote";
            enabled = true;
            oauth = {};
            url = "https://mcp.linear.app/mcp";
          };
        };
      };
    };
  };

  den.aspects.llms = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.opencode
        pkgs.codex
        # Claude Desktop. FHS variant
        inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
      ];
    };
  };
}
