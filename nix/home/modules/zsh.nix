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

        # System rebuilds (includes home-manager integrated)
        # Automatically uses current hostname
        nos = "sudo nixos-rebuild switch --flake ~/configs/nix#$HOST";
        nom = "sudo darwin-rebuild switch --flake ~/configs/nix#$HOST";

        # Combined (update flake + rebuild system)
        nosu = "cd ~/configs/nix && nix flake update && sudo nixos-rebuild switch --flake .#$HOST";

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
