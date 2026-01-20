{lib, ...}: {
  imports = [
    # System configuration modules
    ./base-system.nix
    ./locale-time.nix
    ./desktop-wayland.nix
    ./media.nix
    ./graphics.nix
    ./minimal-packages.nix

    # Optional features
    ./gaming.nix
    ./virtualization.nix
    ./hybrid-gpu.nix
    # Software
    ./jetbrains.nix
  ];

  # Set module defaults
  # Core system (enabled by default)
  base-system.enable = lib.mkDefault true;
  locale-time.enable = lib.mkDefault true;
  minimal-packages.enable = lib.mkDefault true;

  # Desktop and hardware (disabled by default)
  desktop-wayland.enable = lib.mkDefault false;
  graphics-config.enable = lib.mkDefault false;
  graphics-config.enable32Bit = lib.mkDefault false;

  # Media (disabled by default)
  media-config.audio.enable = lib.mkDefault false;
  media-config.bluetooth.enable = lib.mkDefault false;

  # Optional features (disabled by default)
  gaming-config.enable = lib.mkDefault false;
  virtualization-config.enable = lib.mkDefault false;

  # Hybrid GPU configuration (disabled by default)
  hybrid-gpu.enable = lib.mkDefault false;
  hybrid-gpu.nvidiaOnly.enable = lib.mkDefault true;

  # Software
  jetbrains.enable = lib.mkDefault false;
}
