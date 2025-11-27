{
  pkgs,
  user,
  hostname,
  ...
}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
    pkgs.home-manager
  ];

  nix.enable = false;
  # Necessary for using flakes on this system. (Should not be necessary if it's not enable I think)
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # System configuration
  programs.fish.enable = true;

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
    swapLeftCtrlAndFn = true;
  };

  # Homebrew configuration for GUI apps and some CLI tools
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "nikitabobko/tap" # Required for aerospace
    ];
    brews = [
      "cargo-binstall"
      "reattach-to-user-namespace"
      "openssl@3"
    ];
    casks = [
      "alacritty"
      "nikitabobko/tap/aerospace" # Window manager
      "font-jetbrains-mono-nerd-font"
      "font-symbols-only-nerd-font"
    ];
  };

  networking.hostName = "${hostname}";
  users.knownUsers = [user];
  system.primaryUser = user;
  users.users.${user} = {
    uid = 501;
    shell = pkgs.fish;
    home = "/Users/${user}";
  };
}
