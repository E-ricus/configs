{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    tmux-config.enable =
      lib.mkEnableOption "enables tmux configuration";
  };

  config = lib.mkIf config.tmux-config.enable {
    programs.tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        yank
      ];
      extraConfig = builtins.readFile ../config/tmux/tmux.conf;
    };
  };
}
