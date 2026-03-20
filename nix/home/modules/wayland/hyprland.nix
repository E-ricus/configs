{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./noctalia.nix
  ];
  options = {
    hyprland-config = {
      xwayland-zero-scale = {
        enable = lib.mkEnableOption "enables XWayland zero scaling (fixes 4K scaling issues)";
      };
      wlr-drm-device = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "WLR_DRM_DEVICES value to prefer specific GPU (e.g., /dev/dri/card1 for iGPU)";
      };
    };
  };

  config = let
    sattyCmd = "satty --copy-command wl-copy -f - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png";

    brightnessScript = pkgs.writeShellScript "brightness-control" (builtins.readFile ../../config/wayland/brightness-control.sh);
    volumeScript = pkgs.writeShellScript "volume-control" (builtins.readFile ../../config/wayland/volume-control.sh);

    # Conditional lock script
    lockScript =
      if config.noctalia-config.enable
      then
        pkgs.writeShellScript "lock-screen" ''
          ${config.programs.noctalia-shell.package}/bin/noctalia-shell ipc call lockScreen lock
        ''
      else
        pkgs.writeShellScript "lock-screen" ''
          ${pkgs.hyprlock}/bin/hyprlock
        '';
  in
    lib.mkIf (config.wayland.enable && config.wayland.compositor == "hyprland") {
      programs.fuzzel.enable = true;

      hyprland-config.xwayland-zero-scale.enable = lib.mkDefault false;

      home.packages = with pkgs;
        [
          grim
          slurp
        ]
        ++ lib.optionals (!config.noctalia-config.enable) [
          hyprlock
          hyprpaper
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
          "$terminal" = "ghostty";
          "$menu" =
            if config.noctalia-config.enable
            then "noctalia-shell ipc call launcher toggle"
            else "fuzzel";

          misc.focus_on_activate = true;

          monitor = [
            ",preferred,auto,auto"
          ];

          exec-once =
            (lib.optionals config.noctalia-config.enable [
              "noctalia-shell"
            ])
            ++ (lib.optionals (!config.noctalia-config.enable) [
              "hyprpaper"
            ]);

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
            "$mod ALT, L, exec, ${lockScript}"

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
            ", XF86AudioRaiseVolume, exec, ${
              if config.noctalia-config.enable
              then "noctalia-shell ipc call volume increase"
              else "${volumeScript} raise"
            }"
            ", XF86AudioLowerVolume, exec, ${
              if config.noctalia-config.enable
              then "noctalia-shell ipc call volume decrease"
              else "${volumeScript} lower"
            }"
            ", XF86AudioMute, exec, ${
              if config.noctalia-config.enable
              then "noctalia-shell ipc call volume muteOutput"
              else "${volumeScript} toggle-mute"
            }"

            # Brightness
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
        (lib.optionals (config.hyprland-config.wlr-drm-device != null) [
          "WLR_DRM_DEVICES,${config.hyprland-config.wlr-drm-device}"
        ])
        ++ lib.optionals config.noctalia-config.enable [
          "NOCTALIA_PAM_SERVICE,noctalia"
        ]
        ++ lib.optionals config.hyprland-config.xwayland-zero-scale.enable (let
          scale = config.wayland.scale;
          cursorSize = builtins.floor (16 * scale);
        in [
          "GDK_SCALE,${toString scale}"
          "QT_SCALE_FACTOR,${toString scale}"
          "XCURSOR_SIZE,${toString cursorSize}"
        ]);

      # Conditional XWayland zero scaling
      wayland.windowManager.hyprland.settings.xwayland = lib.mkIf config.hyprland-config.xwayland-zero-scale.enable {
        force_zero_scaling = true;
      };

      # Screenshots
      programs.satty = {
        enable = true;
        settings = {
          general = {
            initial-tool = "brush";
          };
        };
      };

      # Idle management
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "${lockScript}";
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
              on-timeout = "systemctl suspend-then-hibernate";
            }
          ];
        };
      };
    };
}
