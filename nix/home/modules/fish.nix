{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    fish-config.enable =
      lib.mkEnableOption "enables fish shell configuration";
  };

  config = lib.mkIf config.fish-config.enable {
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
        hm = "home-manager switch --flake ~/configs/nix#$USER-(hostname)";
        hmu = "cd ~/configs/nix && nix flake update && home-manager switch --flake .#$USER-(hostname)";

        # System rebuilds (includes home-manager)
        # Automatically uses current hostname
        nos = "sudo nixos-rebuild switch --flake ~/configs/nix#(hostname)";
        nom = "sudo darwin-rebuild switch --flake ~/configs/nix#(hostname)";

        # Combined (update flake + rebuild system)
        nosu = "cd ~/configs/nix && nix flake update && sudo nixos-rebuild switch --flake .#(hostname)";

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

      # Import from external file
      interactiveShellInit = builtins.readFile ../config/fish/init.fish;
    };
  };
}
