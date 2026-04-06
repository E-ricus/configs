# CLI tools — essential utilities included for all hosts.
{den, ...}: {
  den.aspects.tools = {
    homeManager = {pkgs, ...}: {
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
  };
}
