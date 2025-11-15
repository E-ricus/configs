{lib, ...}: {
  imports = [
    ./gaming.nix
    ./virtualization.nix
  ];

  # Set module defaults - all disabled by default
  gaming-config.enable = lib.mkDefault false;
  virtualization-config.enable = lib.mkDefault false;
}
