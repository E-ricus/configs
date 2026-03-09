{lib, ...}: {
  imports = [
    # System configuration modules
    ./base-system.nix
    ./boot-config.nix
    ./locale-time.nix
    ./desktop-wayland.nix
    ./media.nix
    ./graphics.nix
    ./minimal-packages.nix

    # Optional features
    ./gaming.nix
    ./virtualization.nix
    ./windows-vm.nix
    ./hybrid-gpu.nix
    # Hardware
    ./keyboards.nix
    # Software
    ./jetbrains.nix
    ./work.nix
  ];

  # Set module defaults
  # Core system (enabled by default)
  base-system.enable = lib.mkDefault true;
  boot-config.enable = lib.mkDefault true;
  locale-time.enable = lib.mkDefault true;
  minimal-packages.enable = lib.mkDefault true;

  # Desktop and hardware (disabled by default)
  desktop-wayland.enable = lib.mkDefault false;
  graphics-config.enable = lib.mkDefault false;
  graphics-config.enable32Bit = lib.mkDefault false;
  graphics-config.intel.enable = lib.mkDefault false;

  # Media (disabled by default)
  media-config.audio.enable = lib.mkDefault false;
  media-config.bluetooth.enable = lib.mkDefault false;

  # Optional features (disabled by default)
  gaming-config.enable = lib.mkDefault false;
  gaming-config.minecraft.enable = lib.mkDefault false;
  virtualization-config.enable = lib.mkDefault false;
  windows-vm.enable = lib.mkDefault false;

  # Hybrid GPU configuration (disabled by default)
  hybrid-gpu.enable = lib.mkDefault false;
  hybrid-gpu.nvidiaOnly.enable = lib.mkDefault true;

  # Keyboards
  keyboards-config.zsa.enable = lib.mkDefault false;

  # Software
  jetbrains.enable = lib.mkDefault false;
  work.enable = lib.mkDefault false;
}
