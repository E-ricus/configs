{
  config,
  lib,
  pkgs,
  hostname,
  ...
}: {
  options = {
    base-system.enable =
      lib.mkEnableOption "enables base system configuration";
  };

  config = lib.mkIf config.base-system.enable {
    # Networking
    networking.hostName = "${hostname}";
    networking.networkmanager.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable flakes
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nix.settings.stalled-download-timeout = 0;

    # Disable command-not-found (prevents database errors with flakes)
    programs.command-not-found.enable = false;
    programs.nix-index.enable = true;

    # Garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };

    # System state version
    system.stateVersion = "25.11";
    services.fwupd.enable = true;
  };
}
