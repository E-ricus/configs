{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    desktop-wayland = {
      enable =
        lib.mkEnableOption "enables Wayland desktop environment";
      # TODO: These should be mutually exclusive?
      hyprland.enable = lib.mkEnableOption "enables Hyprland wm";
      niri.enable = lib.mkEnableOption "enables niri wm";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.desktop-wayland.enable {
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

      # XDG Portal (needed for screen sharing, file pickers, etc.)
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };

      # Enable polkit (for privilege escalation)
      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true; # secret service

      # Enable dconf (needed for some GTK apps)
      programs.dconf.enable = true;
    })
    (lib.mkIf config.desktop-wayland.hyprland.enable {
      services.displayManager.defaultSession = "hyprland";
      # Enable Hyprland
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    })
    (lib.mkIf config.desktop-wayland.niri.enable {
      programs.niri.enable = true;
      environment.systemPackages = with pkgs; [
        xwayland-satellite # xwayland support
      ];
    })
  ];
}
