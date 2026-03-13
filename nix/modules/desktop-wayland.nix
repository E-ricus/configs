{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.niri
  ];

  options = {
    desktop-wayland = {
      enable =
        lib.mkEnableOption "enables Wayland desktop environment";

      compositor = lib.mkOption {
        type = lib.types.enum ["hyprland" "niri"];
        default = "hyprland";
        description = "Which Wayland compositor to use";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.desktop-wayland.enable {
      # Add niri overlay for niri-stable/niri-unstable packages
      nixpkgs.overlays = [
        inputs.niri.overlays.niri
      ];

      # Display manager - greetd with ReGreet (GTK4 graphical greeter)
      programs.regreet = {
        enable = true;
        cageArgs = ["-s" "-d"];
        settings = {
          GTK.application_prefer_dark_theme = true;
          appearance.greeting_msg = "Welcome";
        };
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        cursorTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        font = {
          name = "JetBrainsMono Nerd Font";
          package = pkgs.nerd-fonts.jetbrains-mono;
          size = 14;
        };
        extraCss = builtins.readFile ./config/regreet-style.css;
      };

      # Fix 20-second GTK4 startup delay in greeter
      systemd.services.greetd.environment = {
        GTK_USE_PORTAL = "0";
        GDK_DEBUG = "no-portals";
      };
      # Enable polkit (for privilege escalation)
      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true; # secret service

      # Enable dconf (needed for some GTK apps)
      programs.dconf.enable = true;

      # Enable power management services (useful for both compositors)
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
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
      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
      environment.systemPackages = with pkgs; [
        xwayland-satellite # xwayland support
      ];
    })
  ];
}
