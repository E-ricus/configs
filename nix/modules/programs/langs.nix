# Languages, LSPs, formatters.
{...}: {
  flake.modules.homeManager.langs = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Languages
      nodejs
      go
      rustup
      zig
      typst
      odin
      # Formatters
      alejandra
      stylua
      # LSPs
      nixd
      tinymist
      clang-tools
      lua-language-server
      gopls
      vtsls
    ];
  };

  # Sub-aspect for package managers (opt-in per host)
  flake.modules.homeManager.langs-package-managers = {pkgs, ...}: {
    home.packages = [pkgs.pixi];
  };
}
