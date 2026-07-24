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
  perSystem = {pkgs, ...}: {
    packages.opencode = inputs.wrapper-modules.wrappers.opencode.wrap {
      inherit pkgs;
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
