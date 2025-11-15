{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    common-packages.enable =
      lib.mkEnableOption "enables common packages and configuration";
  };

  config = lib.mkIf config.common-packages.enable {
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
      gh

      neovim # not ready to give my config to nix
      # needed for neovim
      luajitPackages.luarocks-nix

      # Development
      nodejs
      go
      rustup
      zig
      just
      #Formatters
      alejandra
      stylua
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
    programs.jujutsu.enable = true;
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      # fish enabled by default
      nix-direnv.enable = true;
      config = {
        whitelist.prefix = ["~/code/" "~/Projects"];
      };
    };
  };
}
