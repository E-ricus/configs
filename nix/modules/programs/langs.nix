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
