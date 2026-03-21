{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./noctalia.nix
  ];

  config = lib.mkIf pkgs.stdenv.isLinux (
    let
      noctalia = cmd:
        [
          "noctalia-shell"
          "ipc"
          "call"
        ]
        ++ (pkgs.lib.splitString " " cmd);

      dms = cmd:
        [
          "dms"
          "ipc"
          "call"
        ]
        ++ (pkgs.lib.splitString " " cmd);

      brightnessScript = pkgs.writeShellScript "brightness-control" (builtins.readFile ../../config/wayland/brightness-control.sh);
      volumeScript = pkgs.writeShellScript "volume-control" (builtins.readFile ../../config/wayland/volume-control.sh);

      isDms = config.dms-config.enable;
      isNoctalia = config.noctalia-config.enable;

      # Lock command depends on which shell is active:
      # - DMS: uses built-in session-lock via IPC
      # - Noctalia: uses its lock screen via IPC
      # - Neither: falls back to hyprlock
      lockScript =
        if isDms
        then
          pkgs.writeShellScript "lock-screen" ''
            dms ipc lock lock
          ''
        else if isNoctalia
        then
          pkgs.writeShellScript "lock-screen" ''
            ${config.programs.noctalia-shell.package}/bin/noctalia-shell ipc call lockScreen lock
          ''
        else
          pkgs.writeShellScript "lock-screen" ''
            ${pkgs.hyprlock}/bin/hyprlock &
          '';
    in
      lib.mkIf (config.wayland.enable && config.wayland.compositor == "niri") {
        #
        programs.fuzzel.enable = true;
        programs.niri.settings = {
          environment = lib.mkMerge [
            (lib.mkIf isNoctalia {
              NOCTALIA_PAM_SERVICE = "noctalia";
            })
            {
              ELECTRON_OZONE_PLATFORM_HINT = "auto";
              # Workaround for Qt6 Wayland use-after-free crash in
              # QWaylandSurface::surface_enter when outputs are removed
              # (e.g. unplugging external monitor with lid closed).
              QT_WAYLAND_RECONNECT = "1";
            }
          ];

          workspaces = {
            "01".name = "1";
            "02".name = "2";
            "03".name = "3";
            "04".name = "4";
            "05".name = "5";
          };

          input = {
            keyboard = {
              xkb = {
                layout = "us";
                options = "compose:ralt";
              };
            };
            touchpad = {
              tap = true;
              natural-scroll = true;
            };
            focus-follows-mouse = {
              enable = false;
              max-scroll-amount = "90%";
            };
          };

          cursor = {
            theme = "Adwaita";
            size = 24;
          };

          gestures = {
            hot-corners.enable = false;
          };

          outputs."eDP-1" = {
            scale = config.wayland.scale;
          };

          layout = {
            gaps = 8;
            center-focused-column = "never";
            preset-column-widths = [
              {proportion = 0.33333;}
              {proportion = 0.5;}
              {proportion = 0.66667;}
            ];
            default-column-width = {proportion = 0.5;};
            focus-ring = {
              enable = true;
              width = 4;
              active.color = "#7fc8ff";
              inactive.color = "#505050";
            };
            border = {
              enable = false;
              width = 4;
              active.color = "#ffc87f";
              inactive.color = "#505050";
            };
            struts = {};
          };

          spawn-at-startup = lib.optionals isNoctalia [{command = ["noctalia-shell"];}];

          prefer-no-csd = true;
          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

          hotkey-overlay.skip-at-startup = true;

          overview = {
            backdrop-color = "#26233a";
          };

          # -- Layer rules for DMS --
          # When DMS is active, place its wallpaper layers within the backdrop
          # so they appear in the niri overview.
          layer-rules = lib.optionals isDms [
            {
              matches = [{namespace = "^quickshell$";}];
              place-within-backdrop = true;
            }
            {
              matches = [{namespace = "dms:blurwallpaper";}];
              place-within-backdrop = true;
            }
          ];

          window-rules =
            [
              {
                matches = [{app-id = "^org\\.wezfurlong\\.wezterm$";}];
                default-column-width = {};
              }
              {
                matches = [
                  {
                    app-id = "firefox$";
                    title = "^Picture-in-Picture$";
                  }
                ];
                open-floating = true;
              }
              {
                matches = [{app-id = ".*";}];
                geometry-corner-radius = {
                  top-left = 8.0;
                  top-right = 8.0;
                  bottom-right = 8.0;
                  bottom-left = 8.0;
                };
                clip-to-geometry = true;
              }
            ]
            # DMS quickshell windows should open floating
            ++ lib.optionals isDms [
              {
                matches = [{app-id = "^org\\.quickshell$";}];
                open-floating = true;
              }
            ];

          binds = let
            # Helper: mark a binding as not inhibitable, so niri always
            # intercepts it even when keyboard-shortcuts-inhibit is active
            # (e.g. when a VM has focus). Merges with any existing attrs.
            ni = attrs: attrs // {allow-inhibiting = false;};

            launcherBind =
              if isDms
              then ni {action.spawn = dms "spotlight toggle";}
              else if isNoctalia
              then ni {action.spawn = noctalia "launcher toggle";}
              else ni {action.spawn = ["fuzzel"];};

            lockBind =
              if isDms
              then ni {action.spawn = dms "lock lock";}
              else if isNoctalia
              then ni {action.spawn = noctalia "lockScreen lock";}
              else ni {action.spawn = ["hyprlock"];};

            volumeRaiseBind =
              if isDms
              then {
                allow-when-locked = true;
                action.spawn = dms "audio increment 3";
              }
              else if isNoctalia
              then {
                allow-when-locked = true;
                action.spawn = noctalia "volume increase";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${volumeScript}" "raise"];
              };

            volumeLowerBind =
              if isDms
              then {
                allow-when-locked = true;
                action.spawn = dms "audio decrement 3";
              }
              else if isNoctalia
              then {
                allow-when-locked = true;
                action.spawn = noctalia "volume decrease";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${volumeScript}" "lower"];
              };

            volumeMuteBind =
              if isDms
              then {
                allow-when-locked = true;
                action.spawn = dms "audio mute";
              }
              else if isNoctalia
              then {
                allow-when-locked = true;
                action.spawn = noctalia "volume muteOutput";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${volumeScript}" "toggle-mute"];
              };

            brightnessUpBind =
              if isDms
              then {
                allow-when-locked = true;
                action.spawn = dms "brightness increment 5 ";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${brightnessScript}" "raise"];
              };

            brightnessDownBind =
              if isDms
              then {
                allow-when-locked = true;
                action.spawn = dms "brightness decrement 5 ";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${brightnessScript}" "lower"];
              };
          in
            {
              "Mod+Shift+Slash" = ni {action.show-hotkey-overlay = {};};
              "Mod+Return" = ni {action.spawn = ["ghostty"];};
              "Mod+D" = launcherBind;
              "Mod+Shift+D" = ni {action.spawn = ["fuzzel"];}; # fallback launcher (no shell IPC)
              "Mod+E" = ni {action.spawn = ["nautilus"];};
              # Mod+T for toggle-floating (moved from Mod+V to avoid DMS clipboard conflict)
              "Mod+T" = ni {action.toggle-window-floating = {};};
              "Mod+Shift+V" = ni {action.switch-focus-between-floating-and-tiling = {};};
              "Super+Alt+L" = lockBind;

              "Super+Alt+S" = ni {
                allow-when-locked = true;
                action.spawn-sh = "pkill orca || exec orca";
              };

              "XF86AudioRaiseVolume" = volumeRaiseBind;
              "XF86AudioLowerVolume" = volumeLowerBind;
              "XF86AudioMute" = volumeMuteBind;
              "XF86AudioMicMute" =
                if isDms
                then {
                  allow-when-locked = true;
                  action.spawn = dms "audio micmute";
                }
                else {
                  allow-when-locked = true;
                  action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                };

              "XF86AudioPlay" =
                if isDms
                then {
                  allow-when-locked = true;
                  action.spawn = dms "mpris playPause";
                }
                else {
                  allow-when-locked = true;
                  action.spawn-sh = "playerctl play-pause";
                };
              "XF86AudioStop" =
                if isDms
                then {
                  allow-when-locked = true;
                  action.spawn = dms "mpris stop";
                }
                else {
                  allow-when-locked = true;
                  action.spawn-sh = "playerctl stop";
                };
              "XF86AudioPrev" =
                if isDms
                then {
                  allow-when-locked = true;
                  action.spawn = dms "mpris previous";
                }
                else {
                  allow-when-locked = true;
                  action.spawn-sh = "playerctl previous";
                };
              "XF86AudioNext" =
                if isDms
                then {
                  allow-when-locked = true;
                  action.spawn = dms "mpris next";
                }
                else {
                  allow-when-locked = true;
                  action.spawn-sh = "playerctl next";
                };

              "XF86MonBrightnessUp" = brightnessUpBind;
              "XF86MonBrightnessDown" = brightnessDownBind;

              "Mod+O" = ni {
                repeat = false;
                action.toggle-overview = {};
              };
              "Mod+Q" = ni {
                repeat = false;
                action.close-window = {};
              };

              # Focus navigation
              "Mod+Left" = ni {action.focus-column-left = {};};
              "Mod+Down" = ni {action.focus-window-down = {};};
              "Mod+Up" = ni {action.focus-window-up = {};};
              "Mod+Right" = ni {action.focus-column-right = {};};
              "Mod+H" = ni {action.focus-column-left = {};};
              "Mod+J" = ni {action.focus-window-down = {};};
              "Mod+K" = ni {action.focus-window-up = {};};
              "Mod+L" = ni {action.focus-column-right = {};};

              # Move windows
              "Mod+Shift+Left" = ni {action.move-column-left = {};};
              "Mod+Shift+Down" = ni {action.move-window-down = {};};
              "Mod+Shift+Up" = ni {action.move-window-up = {};};
              "Mod+Shift+Right" = ni {action.move-column-right = {};};
              "Mod+Shift+H" = ni {action.move-column-left = {};};
              "Mod+Shift+J" = ni {action.move-window-down = {};};
              "Mod+Shift+K" = ni {action.move-window-up = {};};
              "Mod+Shift+L" = ni {action.move-column-right = {};};

              "Mod+Home" = ni {action.focus-column-first = {};};
              "Mod+End" = ni {action.focus-column-last = {};};
              "Mod+Ctrl+Home" = ni {action.move-column-to-first = {};};
              "Mod+Ctrl+End" = ni {action.move-column-to-last = {};};

              # Monitor navigation
              "Mod+Ctrl+H" = ni {action.focus-monitor-left = {};};
              "Mod+Ctrl+J" = ni {action.focus-monitor-down = {};};
              "Mod+Ctrl+K" = ni {action.focus-monitor-up = {};};
              "Mod+Ctrl+L" = ni {action.focus-monitor-right = {};};

              "Mod+Shift+Ctrl+H" = ni {action.move-column-to-monitor-left = {};};
              "Mod+Shift+Ctrl+J" = ni {action.move-column-to-monitor-down = {};};
              "Mod+Shift+Ctrl+K" = ni {action.move-column-to-monitor-up = {};};
              "Mod+Shift+Ctrl+L" = ni {action.move-column-to-monitor-right = {};};

              # Workspace navigation
              "Mod+Page_Down" = ni {action.focus-workspace-down = {};};
              "Mod+Page_Up" = ni {action.focus-workspace-up = {};};
              "Mod+U" = ni {action.focus-workspace-down = {};};
              "Mod+I" = ni {action.focus-workspace-up = {};};
              "Mod+Ctrl+Page_Down" = ni {action.move-column-to-workspace-down = {};};
              "Mod+Ctrl+Page_Up" = ni {action.move-column-to-workspace-up = {};};
              "Mod+Ctrl+U" = ni {action.move-column-to-workspace-down = {};};
              "Mod+Ctrl+I" = ni {action.move-column-to-workspace-up = {};};

              "Mod+Shift+Page_Down" = ni {action.move-workspace-down = {};};
              "Mod+Shift+Page_Up" = ni {action.move-workspace-up = {};};
              "Mod+Shift+U" = ni {action.move-workspace-down = {};};
              "Mod+Shift+I" = ni {action.move-workspace-up = {};};

              # Wheel scroll workspace switching
              "Mod+WheelScrollDown" = ni {
                cooldown-ms = 150;
                action.focus-workspace-down = {};
              };
              "Mod+WheelScrollUp" = ni {
                cooldown-ms = 150;
                action.focus-workspace-up = {};
              };
              "Mod+Ctrl+WheelScrollDown" = ni {
                cooldown-ms = 150;
                action.move-column-to-workspace-down = {};
              };
              "Mod+Ctrl+WheelScrollUp" = ni {
                cooldown-ms = 150;
                action.move-column-to-workspace-up = {};
              };

              # Wheel scroll column navigation
              "Mod+WheelScrollRight" = ni {action.focus-column-right = {};};
              "Mod+WheelScrollLeft" = ni {action.focus-column-left = {};};
              "Mod+Ctrl+WheelScrollRight" = ni {action.move-column-right = {};};
              "Mod+Ctrl+WheelScrollLeft" = ni {action.move-column-left = {};};

              "Mod+Shift+WheelScrollDown" = ni {action.focus-column-right = {};};
              "Mod+Shift+WheelScrollUp" = ni {action.focus-column-left = {};};
              "Mod+Ctrl+Shift+WheelScrollDown" = ni {action.move-column-right = {};};
              "Mod+Ctrl+Shift+WheelScrollUp" = ni {action.move-column-left = {};};

              # Workspace switching (1-10)
              "Mod+1" = ni {action.focus-workspace = 1;};
              "Mod+2" = ni {action.focus-workspace = 2;};
              "Mod+3" = ni {action.focus-workspace = 3;};
              "Mod+4" = ni {action.focus-workspace = 4;};
              "Mod+5" = ni {action.focus-workspace = 5;};
              "Mod+6" = ni {action.focus-workspace = 6;};
              "Mod+7" = ni {action.focus-workspace = 7;};
              "Mod+8" = ni {action.focus-workspace = 8;};
              "Mod+9" = ni {action.focus-workspace = 9;};
              "Mod+0" = ni {action.focus-workspace = 10;};

              "Mod+Shift+1" = ni {action.move-column-to-workspace = 1;};
              "Mod+Shift+2" = ni {action.move-column-to-workspace = 2;};
              "Mod+Shift+3" = ni {action.move-column-to-workspace = 3;};
              "Mod+Shift+4" = ni {action.move-column-to-workspace = 4;};
              "Mod+Shift+5" = ni {action.move-column-to-workspace = 5;};
              "Mod+Shift+6" = ni {action.move-column-to-workspace = 6;};
              "Mod+Shift+7" = ni {action.move-column-to-workspace = 7;};
              "Mod+Shift+8" = ni {action.move-column-to-workspace = 8;};
              "Mod+Shift+9" = ni {action.move-column-to-workspace = 9;};
              "Mod+Shift+0" = ni {action.move-column-to-workspace = 10;};

              # Window management
              "Mod+BracketLeft" = ni {action.consume-or-expel-window-left = {};};
              "Mod+BracketRight" = ni {action.consume-or-expel-window-right = {};};
              "Mod+Comma" = ni {action.consume-window-into-column = {};};
              "Mod+Period" = ni {action.expel-window-from-column = {};};

              "Mod+R" = ni {action.switch-preset-column-width = {};};
              "Mod+Shift+R" = ni {action.switch-preset-window-height = {};};
              "Mod+Ctrl+R" = ni {action.reset-window-height = {};};
              "Mod+F" = ni {action.maximize-column = {};};
              "Mod+Shift+F" = ni {action.fullscreen-window = {};};
              "Mod+Ctrl+F" = ni {action.expand-column-to-available-width = {};};

              "Mod+C" = ni {action.center-column = {};};
              "Mod+Ctrl+C" = ni {action.center-visible-columns = {};};

              "Mod+Minus" = ni {action.set-column-width = "-10%";};
              "Mod+Equal" = ni {action.set-column-width = "+10%";};
              "Mod+Shift+Minus" = ni {action.set-window-height = "-10%";};
              "Mod+Shift+Equal" = ni {action.set-window-height = "+10%";};

              "Mod+W" = ni {action.toggle-column-tabbed-display = {};};

              # Screenshots
              "Print" =
                if isDms
                then ni {action.spawn = dms "niri screenshot";}
                else ni {action.screenshot = {};};
              "Ctrl+Print".action.screenshot-screen = {};
              "Alt+Print".action.screenshot-window = {};

              "Mod+Escape" = {
                allow-inhibiting = false;
                action.toggle-keyboard-shortcuts-inhibit = {};
              };

              "Mod+Shift+E" = ni {action.quit = {};};
              "Ctrl+Alt+Delete".action.quit = {};
              "Mod+Shift+P" = ni {action.power-off-monitors = {};};
            }
            # -- DMS-specific keybinds (only when DMS is active) --
            // lib.optionalAttrs isDms {
              # DMS spotlight launcher (alternative to Mod+D)
              "Mod+Space" = ni {action.spawn = dms "spotlight toggle";};
              # Clipboard manager (replaces old Mod+V toggle-floating, now on Mod+T)
              "Mod+V" = ni {action.spawn = dms "clipboard toggle";};
              # Notification center
              "Mod+N" = ni {action.spawn = dms "notifications toggle";};
              # Task / process manager
              "Mod+M" = ni {action.spawn = dms "processlist focusOrToggle";};
              # DMS settings
              "Mod+Shift+Comma" = ni {action.spawn = dms "settings focusOrToggle";};
              # Power menu
              "Mod+X" = ni {action.spawn = dms "powermenu toggle";};
              # Wallpaper browser
              "Mod+Y" = ni {action.spawn = dms "dankdash wallpaper";};
              # Night mode toggle
              "Mod+Alt+N" = ni {
                allow-when-locked = true;
                action.spawn = dms "night toggle";
              };
            };
        };

        home.packages = with pkgs;
          [
            hyprlock # always available as lock screen fallback
          ]
          # Screenshots editor when not using DMS (DMS has built-in niri screenshot)
          ++ lib.optionals (!isDms) [
            satty
          ];

        # Idle management: DMS handles idle/lock natively when enabled.
        # swayidle is only used when DMS is not active.
        services.swayidle = lib.mkIf (!isDms) {
          enable = true;
          systemdTarget = "graphical-session.target";
          events = {
            "before-sleep" = "${lockScript}";
            "lock" = "${lockScript}";
          };
          timeouts = [
            {
              timeout = 300;
              command = "${lockScript}";
            }
            {
              timeout = 600;
              command = "${pkgs.niri-unstable}/bin/niri msg action power-off-monitors";
              resumeCommand = "${pkgs.niri-unstable}/bin/niri msg action power-on-monitors";
            }
            {
              timeout = 1800;
              command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
            }
          ];
        };
      }
  );
}
