{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    zsh-config.enable =
      lib.mkEnableOption "enables zsh shell configuration";
  };

  config = lib.mkIf config.zsh-config.enable {
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

        # Home-manager (standalone - fast iteration)
        hm = "home-manager switch --flake ~/.dotfiles/nix#$USER-$HOST";
        hmu = "cd ~/.dotfiles/nix && nix flake update && home-manager switch --flake .#$USER-$HOST";

        # System rebuilds (includes home-manager)
        # Automatically uses current hostname
        nos = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix#$HOST";
        nom = "sudo darwin-rebuild switch --flake ~/.dotfiles/nix#$HOST";

        # Combined (update flake + rebuild system)
        nosu = "cd ~/.dotfiles/nix && nix flake update && sudo nixos-rebuild switch --flake .#$HOST";

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
  };
}
