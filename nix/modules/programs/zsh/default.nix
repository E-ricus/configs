# Zsh shell configuration.
{den, ...}: {
  den.aspects.zsh = {
    homeManager = {...}: {
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

          nos = "sudo nixos-rebuild switch --flake ~/configs/nix#$HOST";
          nom = "sudo darwin-rebuild switch --flake ~/configs/nix#$HOST";
          nosu = "cd ~/configs/nix && nix flake update && sudo nixos-rebuild switch --flake .#$HOST";
          # Test build without switching
          nob = "sudo nixos-rebuild build --flake ~/configs/nix#$HOST";
          ngc = "sudo nix-collect-garbage --delete-older-than 2d";
        };
        history = {
          size = 5000;
          path = "$HOME/.zsh_history";
          ignoreDups = true;
          ignoreSpace = true;
          share = true;
        };
        initContent = builtins.readFile ./init.zsh;
      };
    };
  };
}
