# Neovim configuration.
{den, ...}: {
  den.aspects.nvim = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        neovim
        luajitPackages.luarocks-nix
      ];
    };
  };
}
