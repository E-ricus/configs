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

    isDms = config.dms-config.enable;
    isNoctalia = config.noctalia-config.enable;

    # Conditional lock script
    lockScript =
      if isDms
      then
        pkgs.writeShellScript "lock-screen" ''
          dms ipc call lock lock
        ''
      else if isNoctalia
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
        lib.optionals (!isDms) [
          grim
          slurp
        ]
        ++ lib.optionals (!isDms && !isNoctalia) [
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
            if isDms
            then "dms ipc call spotlight toggle"
            else if isNoctalia
            then "noctalia-shell ipc call launcher toggle"
            else "fuzzel";

          misc.focus_on_activate = true;

          monitor = [
            ",preferred,auto,auto"
          ];

          exec-once =
            (lib.optionals (isNoctalia && !isDms) [
              "noctalia-shell"
            ])
            ++ (lib.optionals (!isNoctalia && !isDms) [
              "hyprpaper"
            ]);
            # DMS: started via systemd, no exec-once needed

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
              size = 10;
              passes = 4;
              ignore_opacity = true;
              new_optimizations = true;
              xray = false;
              noise = 0.02;
              contrast = 1.1;
              vibrancy = 0.2;
              vibrancy_darkness = 0.3;
            };
            shadow = {
              enabled = true;
              range = 20;
              render_power = 3;
              color = "rgba(00000099)";
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
            "$mod, T, togglefloating"
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
            ", Print, exec, ${
              if isDms
              then "dms screenshot --no-file"
              else "grim -g \"$(slurp)\" - | ${sattyCmd}"
            }"
            "SHIFT, Print, exec, ${
              if isDms
              then "dms screenshot full --no-file"
              else "grim - | ${sattyCmd}"
            }"

            # Volume
            ", XF86AudioRaiseVolume, exec, ${
              if isDms
              then "dms ipc call audio increment 3"
              else if isNoctalia
              then "noctalia-shell ipc call volume increase"
              else "${volumeScript} raise"
            }"
            ", XF86AudioLowerVolume, exec, ${
              if isDms
              then "dms ipc call audio decrement 3"
              else if isNoctalia
              then "noctalia-shell ipc call volume decrease"
              else "${volumeScript} lower"
            }"
            ", XF86AudioMute, exec, ${
              if isDms
              then "dms ipc call audio mute"
              else if isNoctalia
              then "noctalia-shell ipc call volume muteOutput"
              else "${volumeScript} toggle-mute"
            }"

            # Brightness
            ", XF86MonBrightnessUp, exec, ${
              if isDms
              then "dms ipc call brightness increment 5"
              else "${brightnessScript} raise"
            }"
            ", XF86MonBrightnessDown, exec, ${
              if isDms
              then "dms ipc call brightness decrement 5"
              else "${brightnessScript} lower"
            }"
          ]
          # DMS-specific keybinds
          ++ lib.optionals isDms [
            "$mod, space, exec, dms ipc call spotlight toggle"
            "$mod, V, exec, dms ipc call clipboard toggle"
            "$mod, N, exec, dms ipc call notifications toggle"
            "$mod, M, exec, dms ipc call processlist focusOrToggle"
            "$mod SHIFT, comma, exec, dms ipc call settings focusOrToggle"
            "$mod, X, exec, dms ipc call powermenu toggle"
            "$mod, Y, exec, dms ipc call dankdash wallpaper"
            "$mod, TAB, exec, dms ipc call hypr toggleOverview"
            # Night mode
            "$mod SHIFT, N, exec, dms ipc call night toggle"
            # Media (DMS mpris)
            ", XF86AudioPlay, exec, dms ipc call mpris playPause"
            ", XF86AudioNext, exec, dms ipc call mpris next"
            ", XF86AudioPrev, exec, dms ipc call mpris previous"
            ", XF86AudioStop, exec, dms ipc call mpris stop"
          ];

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizeactive"
          ];
        };
      };

      # DMS layer rules for Hyprland.
      # See: danklinux.com/docs/dankmaterialshell/layers
      #
      # Compositor-delegated blur, dim, and animations for DMS surfaces.
      # DMS's own animations and modal dim should be disabled in settings
      # (animationSpeed = "none", modalDarkenBackground = false) so they
      # don't stack with the compositor's effects.
      wayland.windowManager.hyprland.settings.layerrule = lib.optionals isDms [
        # -- Animations --
        "animation slide right, match:namespace dms:control-center"
        "animation slide top, match:namespace dms:workspace-overview"
        # -- Blur on modals --
        "blur on, match:namespace dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal|power-menu|confirm-modal)"
        "ignore_alpha 0, match:namespace dms:(polkit|notification-center-modal|workspace-overview|color-picker|clipboard|spotlight|settings|process-list-modal|power-menu|confirm-modal)"
        # -- Blur on shell components (bar, popouts, etc.) --
        "blur on, match:namespace dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|process-list-popout|battery|popout|app-launcher|dock)"
        "ignore_alpha 0, match:namespace dms:(bar|tooltip|toast|dock-context-menu|tray-menu-window|control-center|notification-center-popout|dash|process-list-popout|battery|popout|app-launcher|dock)"
        # -- Dim behind modals --
        "dim_around on, match:namespace dms:(color-picker|clipboard|spotlight|settings|polkit|power-menu|confirm-modal)"
      ];

      # Float DMS quickshell windows
      wayland.windowManager.hyprland.settings.windowrule = lib.optionals isDms [
        "float on, match:class org.quickshell"
      ];

      wayland.windowManager.hyprland.settings.env =
        (lib.optionals (config.hyprland-config.wlr-drm-device != null) [
          "WLR_DRM_DEVICES,${config.hyprland-config.wlr-drm-device}"
        ])
        ++ lib.optionals isNoctalia [
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

      # Idle management: DMS handles idle/lock natively when enabled.
      # hypridle is only used when DMS is not active.
      services.hypridle = lib.mkIf (!isDms) {
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
