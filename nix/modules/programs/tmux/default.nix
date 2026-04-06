# Tmux configuration.
{den, ...}: {
  den.aspects.tmux = {
    homeManager = {pkgs, ...}: {
      programs.tmux = {
        enable = true;
        plugins = with pkgs.tmuxPlugins; [yank];
        extraConfig = builtins.readFile ./tmux.conf;
      };
    };
  };
}
