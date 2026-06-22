# Base system configuration — networking, nix settings, garbage collection.
# Included by all Linux hosts.
{...}: {
  den.aspects.base-system = {
    nixos = {pkgs, ...}: {
      # Networking
      networking.networkmanager.enable = true;

      # Nix settings
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        stalled-download-timeout = 0;
        # Allow this user to set substituters/keys via CLI flags.
        trusted-users = ["root" "ericus"];
        # Noctalia v5 binary cache — skip compiling the shell locally.
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };

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
