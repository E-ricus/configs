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

      # Home-manager (standalone - fast iteration)
      hm = "home-manager switch --flake ~/.dotfiles/nix#$USER";
      hmu = "cd ~/.dotfiles/nix && nix flake update && home-manager switch --flake .#$USER";

      # System rebuilds (includes home-manager)
      # Change laptop-amd to your host: laptop-amd, laptop-lenovo, or vm-aarch64
      nos = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix#laptop-amd";
      nom = "sudo darwin-rebuild switch --flake ~/.dotfiles/nix#work-mac";

      # Combined (update flake + rebuild system)
      nosu = "cd ~/.dotfiles/nix && nix flake update && sudo nixos-rebuild switch --flake .#laptop-amd";

      ngc = "nix-collect-garbage --delete-older-than 2d";
    };

    plugins = [
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
          sha256 = "1hqqppna8iwjnm8135qdjbd093583qd2kbq8pj507zpb1wn9ihjg";
        };
      }
    ];

    # Import from external file
    interactiveShellInit = builtins.readFile ../config/fish/init.fish;
  };
}
