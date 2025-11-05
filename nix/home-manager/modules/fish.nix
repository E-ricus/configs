{
  config,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;

    shellAbbrs = {
      e = "nvim";
      vimdiff = "nvim -d";
    };

    shellAliases = {
      rg = "rg --files --hidden --glob '!.git'";
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "ls -a";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "lt -a";
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      hm = "home-manager switch --flake ~/.config/home-manager#$USER";
      hmu = "cd ~/.config/home-manager && nix flake update && home-manager switch --flake .#$USER";
      ngc = "nix-collect-garbage --delete-older-than 2d";
    };

    # Import from external file
    interactiveShellInit = builtins.readFile ../config/fish/init.fish;
  };
}
