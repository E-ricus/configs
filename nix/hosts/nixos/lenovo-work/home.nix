{user, ...}: {
  imports = [
    ../../../home/default.nix
  ];

  # Home Manager configuration
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  # Enable modules for this host
  starship-config.enable = true;
  git-config.enable = true;
  wayland = {
    enable = true;
    compositor = "niri";
    scale = 1.75;
  };
  # Desktop shell (pick one: dms-config or noctalia-config)
  dms-config.enable = true;
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
