{
  config,
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
  desktop-wayland.enable = true;
  graphics-config = {
    enable = true;
    enable32Bit = true; # Needed for gaming/Steam
  };
  media-config = {
    audio.enable = true;
    bluetooth.enable = true;
  };
  hybrid-gpu = {
    enable = true;

    # PCI Bus IDs for this specific laptop
    # Find with: lspci | grep VGA
    # Default for single-drive setup
    amdBusId = "PCI:5:0:0"; # AMD Radeon Cezanne
    nvidiaBusId = "PCI:1:0:0"; # NVIDIA RTX 3060 Mobile

    # Enable specializations for different modes
    nvidiaOnly.enable = true; # Boot into nvidia-only mode when needed
    batterySaver.enable = true; # Boot into battery-saver mode when needed
  };
  gaming-config.enable = true;
}
