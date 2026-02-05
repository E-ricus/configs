{lib, ...}: {
  imports = [
    # Platform-specific packages
    ./modules/linux-packages.nix
    ./modules/mac-packages.nix

    # Development tools
    ./modules/basic.nix
    ./modules/git.nix
    ./modules/tmux.nix
    ./modules/editors.nix
    ./modules/langs.nix

    # Terminal emulators
    ./modules/alacritty.nix
    ./modules/ghostty.nix

    # Shell configurations
    ./modules/fish.nix
    ./modules/zsh.nix
    ./modules/nu.nix

    # Wayland
    ./modules/wayland/wayland.nix

    # macOS window manager
    ./modules/aerospace.nix

    # Networking
    ./modules/wireguard.nix
  ];

  # Set module defaults
  basic.enable = lib.mkDefault true;

  # Platform-specific packages
  linux-packages.enable = lib.mkDefault false;
  mac-packages.enable = lib.mkDefault false;

  # Terminal emulators
  alacritty-config.enable = lib.mkDefault false;
  ghostty-config.enable = lib.mkDefault false;

  # Shell configurations
  fish-config.enable = lib.mkDefault false;
  zsh-config.enable = lib.mkDefault false;
  nushell.enable = lib.mkDefault false;

  # Development tools
  git-config.enable = lib.mkDefault false;
  tmux-config.enable = lib.mkDefault false;

  # Editors
  editors.enable = lib.mkDefault false;
  # Lower priority, editors enables it by default
  editors.zed.enable = lib.mkOptionDefault false;

  # langs
  langs.enable = lib.mkDefault false;
  # Lower priority, langs enables it by default
  langs.fmt.enable = lib.mkOptionDefault false;
  langs.lsp.enable = lib.mkOptionDefault false;
  langs.llm.enable = lib.mkOptionDefault false;

  # Wayland (by default uses hyprland)
  wayland.enable = lib.mkDefault false;
  hyprland-config.xwayland-zero-scale.enable = lib.mkDefault false;
  # Lower priority, as each compositor enables them by default
  walker-config.enable = lib.mkOptionDefault false;
  waybar-config.enable = lib.mkOptionDefault false;
  swaybg-config.enable = lib.mkOptionDefault false;
  noctalia-config.enable = lib.mkOptionDefault false;

  # macOS window manager
  aerospace-config.enable = lib.mkDefault false;

  # Networking
  wireguard-config.enable = lib.mkDefault false;
}
