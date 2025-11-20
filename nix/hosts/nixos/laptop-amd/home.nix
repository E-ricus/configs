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
    username = "ericus";
    homeDirectory = "/home/ericus";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  # Enable modules for this host
  linux-packages.enable = true;
  git-config.enable = true;
  editors.enable = true;
  langs.enable = true;
  hyprland-config.enable = true; # Also enables walker and waybar by default
  fish-config.enable = true;
  zsh-config.enable = true;
  alacritty-config.enable = true;
  tmux-config.enable = true;
  ghostty-config.enable = true;
  wireguard-config.enable = true;
}
