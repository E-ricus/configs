# LLM coding tools.
{den, ...}: {
  den.aspects.llms = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        opencode
        codex
      ];
    };
  };
}
