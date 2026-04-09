# Shared Wayland desktop configuration.
# Combined NixOS (greeter, polkit, portals) + home-manager packages.
{...}: {
  den.aspects.wayland = {
    nixos = {...}: {
      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true;
      programs.dconf.enable = true;
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    };

    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs; [
        wl-clipboard
        pavucontrol
        brightnessctl
        playerctl
        libnotify
        gpu-screen-recorder
      ];

      # Noctalia/dms handle notifications
      services.mako = {
        enable = lib.mkDefault false;
        settings = {
          actions = true;
          icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
          font = "JetBrainsMono Nerd Font 10";
          width = 300;
          height = 100;
          margin = "20,30";
          padding = "10";
          anchor = "top-right";
          background-color = "#1e1e2e";
          text-color = "#cdd6f4";
          border-color = "#89b4fa";
          default-timeout = 10000;
          "urgency=low" = {
            default-timeout = 5000;
          };
          "urgency=critical" = {
            text-color = "#f38ba8";
            border-color = "#f38ba8";
            default-timeout = 20000;
          };
        };
      };
    };
  };

  # ReGreet greeter aspect (used when DMS greeter is NOT active)
  den.aspects.wayland-regreet = {
    nixos = {pkgs, ...}: {
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
        extraCss = builtins.readFile ./regreet-style.css;
      };
      systemd.services.greetd.environment = {
        GTK_USE_PORTAL = "0";
        GDK_DEBUG = "no-portals";
      };
    };
  };
}
