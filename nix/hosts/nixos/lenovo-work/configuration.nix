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
    shell = pkgs.nushell;
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

  # Fingerprint (Synaptics 06cb:00f9, natively supported by libfprint)
  services.fprintd.enable = true;
  security.pam.services = {
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
    swaylock.fprintAuth = true;
    gtklock.fprintAuth = true;
  };

  jetbrains.enable = true;
  virtualization-config.enable = true;
  work.enable = true;
}
