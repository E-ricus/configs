{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./common.nix
    ./modules/hypr/hyprland.nix
    # Not available in mac yet
    ./modules/ghostty.nix
  ];

  home = {
    username = "ericus";
    homeDirectory = "/home/ericus";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  # Linux only packages
  home.packages = with pkgs; [
    # File managers
    nautilus

    # Browsers
    firefox
    brave
    # Editors
    # Neovim in common

    # Theming
    papirus-icon-theme

    # Fonts
    font-awesome

    btop

    # C/C++ nightmare
    gcc
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
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
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
}
