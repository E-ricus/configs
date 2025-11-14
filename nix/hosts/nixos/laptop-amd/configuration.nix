{
  config,
  pkgs,
  hostname,
  ...
}: {
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-${hostname}";
  networking.networkmanager.enable = true;

  # Time zone and locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  services.displayManager.defaultSession = "hyprland";

  # XDG Portal (needed for screen sharing, file pickers, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Graphics drivers
  hardware.graphics.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  services.blueman.enable = true;

  # User account
  users.users.ericus = {
    isNormalUser = true;
    description = "Eric";
    extraGroups = ["networkmanager" "wheel" "video" "audio"];
    shell = pkgs.fish; # managed by home-manager
  };

  # System packages (minimal - user packages go in home-manager)
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    home-manager
    fish
  ];

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.hack
  ];

  # Enable polkit (for privilege escalation)
  security.polkit.enable = true;

  programs.fish.enable = true;
  # Enable dconf (needed for some GTK apps)
  programs.dconf.enable = true;

  # Allow unfree packages (for things like Discord, Slack, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable flakes (required for home-manager flake setup)
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Disable command-not-found (prevents database errors with flakes)
  programs.command-not-found.enable = false;
  programs.nix-index.enable = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # System state version
  system.stateVersion = "25.05";
}
