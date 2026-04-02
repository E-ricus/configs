{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    linux-packages.enable =
      lib.mkEnableOption "enables Linux-common packages and configuration";
  };

  config = lib.mkIf config.linux-packages.enable {
    # Linux only packages
    home.packages = with pkgs; [
      # File managers
      nautilus
      jmtpfs # MTP CLI fallback

      # Browsers
      firefox
      brave
      # Editors
      # Neovim in common

      # Fonts
      font-awesome

      btop
      vlc

      # C/C++ nightmare
      gcc
      gnumake
      #Develpment
      podman-compose
    ];

    # linux only programs
    programs.firefox.enable = true;
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
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
      # Silence HM 26.05 warning: gtk4 theme no longer inherits from gtk.theme
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
      platformTheme.name = "gtk";
    };
    # Dev only linux
    services.podman.enable = true;
  };
}
