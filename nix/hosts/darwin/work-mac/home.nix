{...}: {
  imports = [
    ../../../home/default.nix
  ];

  # Home Manager configuration
  home = {
    username = "ericpuentes";
    homeDirectory = "/Users/ericpuentes";
    stateVersion = "25.05";

    # Ensure nix and homebrew paths are in PATH for all shells
    # This is needed because nix.enable = false in darwin configuration
    # TODO: Verify why it stopped working
    sessionPath = [
      "/nix/var/nix/profiles/default/bin" # determinate's nix binaries
      "/etc/profiles/per-user/ericpuentes/bin" # Home-manager packages
      "/run/current-system/sw/bin" # Darwin system packages
      "/opt/homebrew/bin" # Homebrew packages
      "/opt/homebrew/sbin" # Homebrew system binaries
    ];
  };

  programs.home-manager.enable = true;

  # Enable modules for this host
  git-config.enable = true;
  editors = {
    enable = true;
    zed.enable = false;
  };
  langs.enable = true;
  fish-config.enable = true;
  zsh-config.enable = true;
  nushell.enable = true;
  alacritty-config.enable = true;
  ghostty-config.enable = true;
  tmux-config.enable = true;
  mac-packages.enable = true;
  aerospace-config.enable = true;
}
