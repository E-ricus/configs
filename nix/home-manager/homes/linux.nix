{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./../common.nix
    ./../modules/hypr/hyprland.nix
  ];

  home = {
    username = "ericus";
    homeDirectory = "/home/ericus";
    stateVersion = "25.05";
  };

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
  ];

  programs.home-manager.enable = true;

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
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
