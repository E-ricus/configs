{lib, ...}: {
  imports = [
    # Common configuration
    ./common.nix

    # Platform-specific packages
    ./modules/linux-packages.nix
    ./modules/mac-packages.nix

    # Terminal emulators
    ./modules/alacritty.nix
    ./modules/ghostty.nix

    # Shell configurations
    ./modules/fish.nix
    ./modules/zsh.nix

    # Development tools
    ./modules/git.nix
    ./modules/tmux.nix

    # Hyprland (imports walker and waybar automatically)
    ./modules/hypr/hyprland.nix

    # macOS window manager
    ./modules/aerospace.nix

    # Networking
    ./modules/wireguard.nix
  ];

  # Set module defaults
  # Common is enabled by default, everything else is opt-in
  common-packages.enable = lib.mkDefault true;

  # Platform-specific packages
  linux-packages.enable = lib.mkDefault false;
  mac-packages.enable = lib.mkDefault false;

  # Terminal emulators
  alacritty-config.enable = lib.mkDefault false;
  ghostty-config.enable = lib.mkDefault false;

  # Shell configurations
  fish-config.enable = lib.mkDefault false;
  zsh-config.enable = lib.mkDefault false;

  # Development tools
  git-config.enable = lib.mkDefault false;
  tmux-config.enable = lib.mkDefault false;

  # Hyprland
  hyprland-config.enable = lib.mkDefault false;
  hyprland-config.xwayland-zero-scale.enable = lib.mkDefault false;
  # Lower priority, as hyprland enables them by default
  walker-config.enable = lib.mkOptionDefault false;
  waybar-config.enable = lib.mkOptionDefault false;

  # macOS window manager
  aerospace-config.enable = lib.mkDefault false;

  # Networking
  wireguard-config.enable = lib.mkDefault false;
}
