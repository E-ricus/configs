{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    basic.enable =
      lib.mkEnableOption "enables common basic packages and configuration";
  };

  config = lib.mkIf config.basic.enable {
    home.packages = with pkgs; [
      # Essentials
      eza
      fzf
      bat
      fd
      ripgrep
      zoxide

      # Goodies
      starship
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
      enableNushellIntegration = true;
      enableFishIntegration = true;
      # fish enabled by default
      nix-direnv.enable = true;
      config = {
        whitelist.prefix = ["~/code/" "~/Projects"];
      };
    };
  };
}
