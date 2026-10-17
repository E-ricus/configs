# LLM coding tools for work
{inputs, ...}: {
  den.aspects.llms = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        pkgs.codex
        pkgs.claude-code
        # Claude Desktop. FHS variant
        inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
      ];
    };
  };
}
