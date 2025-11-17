{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./walker.nix ./waybar.nix];

  options = {
    hyprland-config = {
      enable = lib.mkEnableOption "enables hyprland window manager configuration";

      xwayland-zero-scale.enable = lib.mkEnableOption "enables XWayland zero scaling (fixes 4K scaling issues)";
    };
  };

  config = let
    sattyCmd = "satty --copy-command wl-copy -f - --output-filename ~/Pictures/screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png";

    brightnessScript = pkgs.writeShellScript "brightness-control" (builtins.readFile ../../config/hypr/brightness-control.sh);
  in
    lib.mkIf config.hyprland-config.enable {
      # Enable walker and waybar by default when hyprland is enabled
      walker-config.enable = lib.mkDefault true;
      waybar-config.enable = lib.mkDefault true;

      hyprland-config.xwayland-zero-scale.enable = lib.mkDefault false;

      home.packages = with pkgs; [
        hyprlock
        wl-clipboard
        grim
        slurp
        hyprpaper
        networkmanagerapplet
        pavucontrol
        brightnessctl
        libnotify
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        package = pkgs.hyprland;
        xwayland.enable = true;
        systemd = {
          enable = true;
          variables = ["--all"];
        };
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
            "hyprpaper"
            # for walker menu, it might not be needed:
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
            kb_options = ["compose:ralt"];
            touchpad = {
              natural_scroll = true;
            };
            sensitivity = 0;
          };

          bind = [
            "$mod, Return, exec, $terminal"
            "$mod, F,fullscreen"
            "$mod, E, exec, nautilus"
            "$mod, Q, killactive,"
            "$mod, V, togglefloating"
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
            ", Print, exec, grim -g \"$(slurp)\" - | ${sattyCmd}"
            "SHIFT, Print, exec, grim - | ${sattyCmd}"

            # Volume
            ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
            ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
            ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"

            # Brightness
            # swayosd not working nicely with multiple gpus
            # ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
            # ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
            ", XF86MonBrightnessUp, exec, ${brightnessScript} raise"
            ", XF86MonBrightnessDown, exec, ${brightnessScript} lower"
          ];

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizeactive"
          ];
        };
      };

      wayland.windowManager.hyprland.settings.env =
        [
          # TODO: This is specific for the lenovo laptop, make it configurable if needed
          "WLR_DRM_DEVICES,/dev/dri/card1" #Prefer iGPU
        ]
        ++ lib.optionals config.hyprland-config.xwayland-zero-scale.enable [
          "GDK_SCALE,2"
          "QT_SCALE_FACTOR,2"
          "XCURSOR_SIZE,32"
        ];

      # Conditional XWayland zero scaling
      wayland.windowManager.hyprland.settings.xwayland = lib.mkIf config.hyprland-config.xwayland-zero-scale.enable {
        force_zero_scaling = true;
      };

      # Nice common actions (volume, brightness)
      services.swayosd.enable = true;

      # Screenshots
      programs.satty.enable = true;

      # Notifications
      services.mako = {
        enable = true;
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

      # Idle management
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };

          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 600;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    };
}
