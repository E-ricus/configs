{
  pkgs,
  user,
  ...
}: {
  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "Eric";
    extraGroups = ["networkmanager" "wheel" "video" "audio"];
    shell = pkgs.fish;
  };

  # Enable modules
  desktop-wayland = {
    enable = true;
    compositor = "niri";
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

  # Fingerprint
  services.fprintd = {
    enable = true;
    tod.enable = true;
    # driver for elantech sensor
    tod.driver = pkgs.libfprint-2-tod1-elan;
  };
  security.pam.services = {
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
    swaylock.fprintAuth = true;
    gtklock.fprintAuth = true;
  };
}
