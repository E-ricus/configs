# Languages, LSPs, formatters.
{den, ...}: {
  den.aspects.langs = {
    homeManager = {pkgs, ...}: {
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
        ols
        lua-language-server
        gopls
      ];
    };

    # Sub-aspect for package managers (opt-in per host)
    provides.package-managers = {
      homeManager = {pkgs, ...}: {
        home.packages = [pkgs.pixi];
      };
    };
  };
}
