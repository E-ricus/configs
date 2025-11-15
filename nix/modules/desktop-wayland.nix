{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    desktop-wayland.enable =
      lib.mkEnableOption "enables Wayland desktop environment (Hyprland)";
  };

  config = lib.mkIf config.desktop-wayland.enable {
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Display manager - greetd with tuigreet
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    services.displayManager.defaultSession = "hyprland";

    # XDG Portal (needed for screen sharing, file pickers, etc.)
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    # Enable polkit (for privilege escalation)
    security.polkit.enable = true;

    # Enable dconf (needed for some GTK apps)
    programs.dconf.enable = true;
  };
}
