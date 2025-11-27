{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    dev-packages.enable =
      lib.mkEnableOption "enables common dev packages and configuration";
  };

  config = lib.mkIf config.dev-packages.enable {
    home.packages = with pkgs; [
      # Essentials
      eza
      fzf
      bat
      fd
      ripgrep
      zoxide

      # Goodies
      htop
      stow
      jq
      hexyl
      tree-sitter
      gh
      just
    ];

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    # Common dev programs
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
