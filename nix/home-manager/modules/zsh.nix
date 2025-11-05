{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;

    shellAliases = {
      e = "nvim";
      czsh = "nvim ~/.zshrc";
      cnvim = "cd $XDG_CONFIG_HOME/nvim/ && nvim";
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "ls -a";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "lt -a";
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      hm = "home-manager switch --flake ~/.config/home-manager#$USER";
      hmu = "cd ~/.config/home-manager && nix flake update && home-manager switch --flake .#$USER";
      ngc = "nix-collect-garbage --delete-older-than 2d";
    };

    history = {
      size = 5000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # Import from external file (includes zinit!)
    initContent = builtins.readFile ../config/zsh/init.zsh;
  };
}
