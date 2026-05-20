# COSMIC desktop (System76) — selectable alongside niri at the greeter.
# Adds a `cosmic` wayland session to /run/current-system/sw/share/wayland-sessions/
# that ReGreet auto-discovers. Niri remains the default session.
{den, ...}: {
  den.aspects.cosmic = {
    includes = [
      den.aspects.wayland
      den.aspects.wayland-regreet
    ];

    nixos = {pkgs, ...}: {
      services.desktopManager.cosmic.enable = true;
      services.desktopManager.cosmic.xwayland.enable = true;

      # xdg-desktop-portal-cosmic is auto-enabled by the cosmic module,
      # but listing it explicitly is harmless and merges with niri's gnome portal.
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-cosmic];
      };

      # Useful first-party COSMIC apps not always pulled in by default.
      environment.systemPackages = with pkgs; [
        cosmic-edit
        cosmic-files
        cosmic-term
      ];
    };
  };
}
