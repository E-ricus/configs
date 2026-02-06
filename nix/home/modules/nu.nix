{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nushell.enable =
      lib.mkEnableOption "enables nu shell configuration";
  };

  config = lib.mkIf config.nushell.enable {
    home.packages = with pkgs; [
      nu_scripts
      nufmt
    ];
    programs.nushell = {
      enable = true;
      shellAliases = {
        rg = "rg --files --hidden --glob '!.git'";
        ff = "fzf --preview 'bat --style=numbers --color=always {}'";
        e = "nvim";
        vimdiff = "nvim -d";
        ngc = "sudo nix-collect-garbage --delete-older-than 2d";
      };

      settings = {
        show_banner = false;
        edit_mode = "vi";
        buffer_editor = "nvim";
        completions = {
          quick = true;
          partial = true;
          algorithm = "fuzzy";
          external = {
            enable = true;
          };
        };
      };
      plugins = [
        pkgs.nushellPlugins.query
      ];
      envFile.source = ../config/nu/env.nu;
      configFile.source = ../config/nu/config.nu;
      extraConfig = ''
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *

      '';
    };
  };
}
