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
  git-config.enable = true;
  hyprland-config = {
    enable = true;
    xwayland-zero-scale.enable = true;
  }; # Also enables walker and waybar by default
  editors.enable = true;
  langs.enable = true;
  fish-config.enable = true;
  zsh-config.enable = true;
  alacritty-config.enable = true;
  tmux-config.enable = true;
  linux-packages.enable = true;
  ghostty-config.enable = true;
  wireguard-config.enable = true;
}
