{
  config,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
    ];
    extraConfig = builtins.readFile ../config/tmux/tmux.conf;
  };
}
