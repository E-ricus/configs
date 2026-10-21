# CLI tools — essential utilities included for all hosts.
{...}: {
  flake.modules.homeManager.tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Essentials
      eza
      fzf
      bat
      fd
      ripgrep
      zoxide
      fastfetch
      # Goodies
      htop
      stow
      jq
      hexyl
      tree-sitter
      gh
      just
      hyperfine
    ];
  };
}
