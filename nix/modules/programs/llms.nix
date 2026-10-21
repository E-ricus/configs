# LLM coding tools for work
{inputs, ...}: {
  flake.modules.homeManager.llms = {pkgs, ...}: {
    home.packages = [
      pkgs.codex
      pkgs.claude-code
      # Claude Desktop. FHS variant
      inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
    ];
  };
}
