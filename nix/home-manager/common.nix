{
  config,
  pkgs,
  ...
}: {
  # Allow unfree packages in home-manager
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./modules/git.nix
    ./modules/fish.nix
    ./modules/zsh.nix
    ./modules/alacritty.nix
    ./modules/tmux.nix
  ];

  home.packages = with pkgs; [
    eza
    fzf
    bat
    fd
    ripgrep
    zoxide
    htop
    stow
    jq
    tree-sitter

    neovim # not ready to give my config to nix
    # needed for neovim
    luajitPackages.luarocks-nix

    # Development
    nodejs
    go
    rustup
    zig
    #Formatters
    alejandra
    # LLMs
    opencode
    claude-code
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Common programs
  programs.yazi.enable = true;
  programs.lazygit.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    # fish enabled by default
    nix-direnv.enable = true;
    config = {
      whitelist.prefix = ["~/code/" "~/Projects"];
    };
  };
}
