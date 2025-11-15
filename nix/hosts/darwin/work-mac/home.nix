{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../../home/default.nix
  ];

  # Home Manager configuration
  home = {
    username = "ericpuentes";
    homeDirectory = "/Users/ericpuentes";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  # Enable modules for this host
  git-config.enable = true;
  fish-config.enable = true;
  zsh-config.enable = true;
  alacritty-config.enable = true;
  tmux-config.enable = true;
  mac-packages.enable = true;
  aerospace-config.enable = true;
}
