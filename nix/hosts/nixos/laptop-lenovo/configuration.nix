{
  pkgs,
  user,
  ...
}: {
  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "Eric";
    extraGroups = ["networkmanager" "wheel" "video" "audio" "plugdev"];
    shell = pkgs.fish;
  };

  # Taken from nixos-hardware
  services.fstrim.enable = true;

  # Enable modules
  desktop-wayland = {
    enable = true;
    compositor = "niri";
    dank.enable = true; # DankGreeter + DMS polkit agent
  };
  graphics-config = {
    enable = true;
    enable32Bit = true;
  };
  media-config = {
    audio.enable = true;
    bluetooth.enable = true;
  };
  hybrid-gpu = {
    enable = true;

    amdBusId = "PCI:5:0:0"; # AMD Radeon
    nvidiaBusId = "PCI:1:0:0"; # NVIDIA RTX 3060 Mobile

    # Enable specializations for different modes
    nvidiaOnly.enable = true; # Boot into nvidia-only mode when needed
  };
  gaming-config = {
    enable = true;
    minecraft.enable = true;
  };

  # Fingerprint authentication with parallel password support
  fingerprint-config = {
    enable = true;
    # driver for elantech sensor
    driver = pkgs.libfprint-2-tod1-elan;
  };
  # Backlight control - udev rules for video group write access
  hardware.brillo.enable = true;

  keyboards-config.zsa.enable = true;
  vpn = {
    enable = true;
    mullvad.enable = true;
  };
}
