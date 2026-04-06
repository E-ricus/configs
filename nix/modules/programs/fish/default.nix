# Fish shell configuration.
{den, ...}: {
  den.aspects.fish = {
    homeManager = {pkgs, ...}: {
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

          nos = "sudo nixos-rebuild switch --flake ~/configs/nix#(hostname)";
          nom = "sudo darwin-rebuild switch --flake ~/configs/nix#(hostname)";
          nosu = "cd ~/configs/nix && nix flake update && sudo nixos-rebuild switch --flake .#(hostname)";
          # Test build without switching
          nob = "sudo nixos-rebuild build --flake ~/configs/nix#(hostname)";
          ngc = "sudo nix-collect-garbage --delete-older-than 2d";
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
        interactiveShellInit = builtins.readFile ./init.fish;
      };
    };
  };
}
