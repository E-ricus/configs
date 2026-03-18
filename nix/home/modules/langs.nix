{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    langs.enable = lib.mkEnableOption "enables langs (compilers, lsp, fmt, etc)";
    langs.fmt.enable = lib.mkEnableOption "enables formatters";
    langs.lsp.enable = lib.mkEnableOption "enables language servers";
    langs.llm.enable = lib.mkEnableOption "enables llms tools";
    langs.pm.enable = lib.mkEnableOption "enables package managers";
  };

  config = lib.mkIf config.editors.enable {
    # Enabled by default if langs is enabled, can be disabled
    langs.fmt.enable = lib.mkDefault true;
    langs.lsp.enable = lib.mkDefault true;
    langs.llm.enable = lib.mkDefault true;
    # I would rather not have them, but somethings are annoying in nix
    langs.pm.enable = lib.mkDefault false;

    home.packages = with pkgs;
      [
        nodejs
        go
        rustup
        zig
        typst
        odin
      ]
      #Formatters
      ++ lib.optionals config.langs.fmt.enable [
        alejandra
        stylua
      ]
      #LSPs
      ++ lib.optionals config.langs.lsp.enable [
        nixd
        tinymist
        clang-tools
        ols
      ]
      # LLMs
      ++ lib.optionals config.langs.llm.enable [
        opencode
        claude-code
        codex
      ]
      # Package managers
      ++ lib.optionals config.langs.pm.enable [
        pixi
      ];
  };
}
