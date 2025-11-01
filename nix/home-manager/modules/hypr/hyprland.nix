{
  config,
  pkgs,
  ...
}: {
  imports = [./walker.nix ./waybar.nix];

  home.packages = with pkgs; [
    swaylock
    swayidle
    wl-clipboard
    grim
    slurp
    hyprpaper
    brightnessctl
    networkmanagerapplet
    pavucontrol
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$menu" = "walker";

      misc.focus_on_activate = true;

      monitor = [
        ",preferred,auto,auto"
      ];

      exec-once = [
        "waybar"
        "dunst"
        "hyprpaper"
        # for walker menu
        "elephant"
        "walker --gapplication-service"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "borderangle, 1, 8, default"
          "workspaces, 1, 6, default"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 0;
      };

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, E, exec, nautilus"
        "$mod, Q, killactive,"
        "$mod, M, exit"
        "$mod, V, togglefloating"
        "$mod, S, togglesplit,"
        "$mod, D, exec, $menu"
        "$mod, P, pseudo,"

        #move focus
        "$mod, h, moveFocus, l"
        "$mod, j, moveFocus, d"
        "$mod, k, moveFocus, u"
        "$mod, l, moveFocus, r"

        #move windows
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"

        #resize windows
        "$mod ALT, h, resizeactive, -10 0"
        "$mod ALT, j, resizeactive, 0 10"
        "$mod ALT, k, resizeactive, 0 -10"
        "$mod ALT, l, resizeactive, 10 0"

        #switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        #send to workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Volume
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # Brightness
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizeactive"
      ];
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "JetBrainsMono Nerd Font 10";
        geometry = "300x5-30+20";
        transparency = 10;
        frame_color = "#89b4fa";
        frame_width = 2;
      };

      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
      };

      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
      };

      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#f38ba8";
      };
    };
  };
}
