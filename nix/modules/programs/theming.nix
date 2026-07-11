# GTK/Qt Catppuccin theming, cursor/icon themes, dconf settings.
{den, ...}: {
  den.aspects.theming = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      # Cursor theme + size. this also exports XCURSOR_THEME /
      # XCURSOR_SIZE into the session environment and sets the X resources.
      home.pointerCursor = {
        enable = true;
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      gtk = {
        enable = true;
        theme = {
          name = "catppuccin-mocha-mauve-standard";
          package = pkgs.catppuccin-gtk.override {
            variant = "mocha";
            accents = ["mauve"];
            size = "standard";
          };
        };
        gtk4.theme = null;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.catppuccin-papirus-folders.override {
            flavor = "mocha";
            accent = "mauve";
          };
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      dconf = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
      };
    };
  };
}
