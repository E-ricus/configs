# Base system configuration — networking, nix settings, garbage collection.
# Included by all Linux hosts.
{...}: {
  den.aspects.base-system = {
    nixos = {pkgs, ...}: {
      # Networking
      networking.networkmanager.enable = true;

      # Nix settings
      nix.settings.experimental-features = ["nix-command" "flakes"];

      # Disable command-not-found (prevents database errors with flakes)
      programs.command-not-found.enable = false;
      programs.nix-index = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };

      # Garbage collection
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 2d";
      };

      # Firmware updates
      services.fwupd.enable = true;

      # Essential system packages
      environment.systemPackages = with pkgs; [
        git
        wget
        curl
        vim
        home-manager
        fish
        usbutils
      ];

      # Enable fish shell system-wide
      programs.fish.enable = true;
    };
  };
}
