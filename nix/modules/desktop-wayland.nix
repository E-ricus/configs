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

      compositor = lib.mkOption {
        type = lib.types.enum ["hyprland" "niri"];
        default = "hyprland";
        description = "Which Wayland compositor to use (mutually exclusive)";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.desktop-wayland.enable {
      # Display manager - greetd with tuigreet
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = let
              compositorCmd =
                if config.desktop-wayland.compositor == "hyprland"
                then "Hyprland"
                else "niri-session";
            in "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${compositorCmd}";
            user = "greeter";
          };
        };
      };
      # Enable polkit (for privilege escalation)
      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true; # secret service

      # Enable dconf (needed for some GTK apps)
      programs.dconf.enable = true;
    })
    (lib.mkIf (config.desktop-wayland.enable && config.desktop-wayland.compositor == "hyprland") {
      services.displayManager.defaultSession = "hyprland";
      # XDG Portal (needed for screen sharing, file pickers, etc.)
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };
      # Enable Hyprland
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };
    })
    (lib.mkIf (config.desktop-wayland.enable && config.desktop-wayland.compositor == "niri") {
      services.displayManager.defaultSession = "niri";
      # XDG Portal (needed for screen sharing, file pickers, etc.)
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gnome];
      };
      programs.niri.enable = true;
      environment.systemPackages = with pkgs; [
        xwayland-satellite # xwayland support
      ];
    })
  ];
}
