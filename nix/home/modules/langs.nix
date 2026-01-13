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
  };

  config = lib.mkIf config.editors.enable {
    # Enabled by default if langs is enabled, can be disabled
    langs.fmt.enable = lib.mkDefault true;
    langs.lsp.enable = lib.mkDefault true;
    langs.llm.enable = lib.mkDefault true;

    home.packages = with pkgs;
      [
        nodejs
        go
        rustup
        zig
        typst
      ]
      #Formatters
      ++ lib.optionals config.langs.fmt.enable [
        alejandra
        stylua
      ]
      #LSPs
      ++ lib.optionals config.langs.lsp.enable [
        nixd
      ]
      # LLMs
      ++ lib.optionals config.langs.lsp.enable [
        opencode
        claude-code
        codex
      ];
  };
}
