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
    compositor = "niri";
  };
  # Use noctalia shell instead of waybar + swaybg
  noctalia-config.enable = true;
  waybar-config.enable = false;
  swaybg-config.enable = false;
  editors.enable = true;
  langs.enable = true;
  fish-config.enable = true;
  zsh-config.enable = true;
  nushell.enable = true;
  alacritty-config.enable = true;
  tmux-config.enable = true;
  linux-packages.enable = true;
  ghostty-config.enable = true;
  wireguard-config.enable = true;
}
