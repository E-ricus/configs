{...}: {
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
  wayland = {
    enable = true;
    compositor = "hyprland";
  };
  # Use noctalia shell instead of waybar + swaybg
  noctalia-config.enable = true;
  # Hyprland configuration
  hyprland-config.wlr-drm-device = "/dev/dri/card1"; # Prefer iGPU
  editors.enable = true;
  langs = {
    enable = true;
    pm.enable = true;
  };
  fish-config.enable = true;
  zsh-config.enable = true;
  nushell.enable = true;
  alacritty-config.enable = true;
  tmux-config.enable = true;
  linux-packages.enable = true;
  ghostty-config.enable = true;
  wireguard-config.enable = true;
}
