{
  config,
  lib,
  ...
}: {
  options = {
    nushell.enable =
      lib.mkEnableOption "enables nu shell configuration";
  };

  config = lib.mkIf config.nushell.enable {
    programs.nushell = {
      enable = true;
      shellAliases = {
        rg = "rg --files --hidden --glob '!.git'";
        ff = "fzf --preview 'bat --style=numbers --color=always {}'";
        e = "nvim";
        vimdiff = "nvim -d";

        # Home-manager (standalone - fast iteration)
        hm = "home-manager switch --flake ~/configs/nix#$USER-(hostname)";
        hmu = "cd ~/configs/nix; nix flake update; home-manager switch --flake .#$USER-(hostname)";

        # System rebuilds (includes home-manager)
        # Automatically uses current hostname
        nos = "sudo nixos-rebuild switch --flake ~/configs/nix#(hostname)";
        nom = "sudo darwin-rebuild switch --flake ~/configs/nix#(hostname)";

        # Combined (update flake + rebuild system)
        nosu = "cd ~/configs/nix; nix flake update; sudo nixos-rebuild switch --flake .#(hostname)";

        ngc = "sudo nix-collect-garbage --delete-older-than 2d";
      };

      settings = {};
    };
  };
}
