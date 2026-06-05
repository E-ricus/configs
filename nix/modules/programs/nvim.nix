{...}: {
  den.aspects.nvim = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        neovim
        neovide
        luajitPackages.luarocks-nix
      ];
    };
  };
}
