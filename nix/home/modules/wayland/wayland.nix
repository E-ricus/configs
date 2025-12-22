{
  config,
  lib,
  pkgs,
  darwin ? false,
  niri ? null,
  ...
}: {
  imports =
    [
      ./hyprland.nix
      ./niri.nix
    ]
    ++ lib.optionals (niri != null && darwin) [
      niri.homeModules.niri
    ];

  options = {
    wayland = {
      enable = lib.mkEnableOption "enables Wayland configuration";

      compositor = lib.mkOption {
        type = lib.types.enum ["hyprland" "niri"];
        default = "hyprland";
        description = "Which Wayland compositor to use";
      };
    };
  };

  config = lib.mkIf config.wayland.enable {
    home.packages = with pkgs; [
      wl-clipboard
      pavucontrol
      brightnessctl
      playerctl
      libnotify
    ];

    # Notifications (can be overridden by noctalia or other modules)
    services.mako = {
      enable = lib.mkDefault true;
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
}
