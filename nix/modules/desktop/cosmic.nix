{den, ...}: {
  den.aspects.cosmic = {
    includes = [
      den.aspects.wayland
      den.aspects.wayland-regreet
    ];

    nixos = {pkgs, ...}: {
      services.desktopManager.cosmic.enable = true;
      services.desktopManager.cosmic.xwayland.enable = true;

      services.system76-scheduler.enable = true;

      # xdg-desktop-portal-cosmic is auto-enabled by the cosmic module,
      # but listing it explicitly is harmless and merges with niri's gnome portal.
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-cosmic];
      };

      environment.systemPackages = with pkgs; [
        cosmic-edit
        cosmic-files
        cosmic-term
        kooha
      ];
    };
  };
}
