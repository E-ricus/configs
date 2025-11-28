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
  desktop-wayland = {
    enable = true;
    hyprland.enable = true;
  };
  graphics-config.enable = true;
  media-config = {
    audio.enable = true;
    bluetooth.enable = true;
  };
  virtualization-config.enable = true;
}
