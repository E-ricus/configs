{user, ...}: {
  imports = [
    ../../../home/default.nix
  ];

  # Home Manager configuration
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  # Enable modules for this host
  starship-config.enable = true;
  git-config.enable = true;
  wayland = {
    enable = true;
    compositor = "niri";
    scale = 2.0;
  };
  # Desktop shell (pick one: dms-config or noctalia-config)
  dms-config.enable = true;
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
