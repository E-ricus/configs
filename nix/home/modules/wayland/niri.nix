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
      brightnessScript = pkgs.writeShellScript "brightness-control" (builtins.readFile ../../config/wayland/brightness-control.sh);
      volumeScript = pkgs.writeShellScript "volume-control" (builtins.readFile ../../config/wayland/volume-control.sh);

      # Use different lock commands based on whether noctalia is enabled
      lockScript =
        if config.noctalia-config.enable
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
        programs.niri.settings = {
          environment = lib.mkMerge [
            (lib.mkIf config.noctalia-config.enable {
              NOCTALIA_PAM_SERVICE = "noctalia";
            })
            {
              QT_QPA_PLATFORM = "wayland";
              ELECTRON_OZONE_PLATFORM_HINT = "auto";
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
            # Seems like is choosing correctly
            #   mode = {
            #     width = 3840;
            #     height = 2160;
            #     refresh = 60.0;
            #   };
            #   transform = {
            #     rotation = 0;
            #     flipped = false;
            #   };
            #   position = {
            #     x = 1280;
            #     y = 0;
            #   };
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

          spawn-at-startup = [{command = ["noctalia-shell"];}];

          prefer-no-csd = true;
          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

          hotkey-overlay.skip-at-startup = true;

          overview = {
            backdrop-color = "#26233a";
          };

          window-rules = [
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
          ];

          binds = let
            # Helper: mark a binding as not inhibitable, so niri always
            # intercepts it even when keyboard-shortcuts-inhibit is active
            # (e.g. when a VM has focus). Merges with any existing attrs.
            ni = attrs: attrs // {allow-inhibiting = false;};

            launcherBind =
              if config.noctalia-config.enable
              then ni {action.spawn = noctalia "launcher toggle";}
              else ni {action.spawn = ["fuzzel"];};

            lockBind =
              if config.noctalia-config.enable
              then ni {action.spawn = noctalia "lockScreen lock";}
              else ni {action.spawn = ["hyprlock"];};

            volumeRaiseBind =
              if config.noctalia-config.enable
              then {
                allow-when-locked = true;
                action.spawn = noctalia "volume increase";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${volumeScript}" "raise"];
              };

            volumeLowerBind =
              if config.noctalia-config.enable
              then {
                allow-when-locked = true;
                action.spawn = noctalia "volume decrease";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${volumeScript}" "lower"];
              };

            volumeMuteBind =
              if config.noctalia-config.enable
              then {
                allow-when-locked = true;
                action.spawn = noctalia "volume muteOutput";
              }
              else {
                allow-when-locked = true;
                action.spawn = ["${volumeScript}" "toggle-mute"];
              };
          in {
            "Mod+Shift+Slash" = ni {action.show-hotkey-overlay = {};};
            "Mod+Return" = ni {action.spawn = ["ghostty"];};
            "Mod+D" = launcherBind;
            "Mod+E" = ni {action.spawn = ["nautilus"];};
            "Mod+V" = ni {action.toggle-window-floating = {};};
            "Mod+Shift+V" = ni {action.switch-focus-between-floating-and-tiling = {};};
            "Super+Alt+L" = lockBind;

            "Super+Alt+S" = ni {
              allow-when-locked = true;
              action.spawn-sh = "pkill orca || exec orca";
            };

            "XF86AudioRaiseVolume" = volumeRaiseBind;
            "XF86AudioLowerVolume" = volumeLowerBind;
            "XF86AudioMute" = volumeMuteBind;
            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            };

            "XF86AudioPlay" = {
              allow-when-locked = true;
              action.spawn-sh = "playerctl play-pause";
            };
            "XF86AudioStop" = {
              allow-when-locked = true;
              action.spawn-sh = "playerctl stop";
            };
            "XF86AudioPrev" = {
              allow-when-locked = true;
              action.spawn-sh = "playerctl previous";
            };
            "XF86AudioNext" = {
              allow-when-locked = true;
              action.spawn-sh = "playerctl next";
            };

            "XF86MonBrightnessUp" = {
              allow-when-locked = true;
              action.spawn = ["${brightnessScript}" "raise"];
            };
            "XF86MonBrightnessDown" = {
              allow-when-locked = true;
              action.spawn = ["${brightnessScript}" "lower"];
            };

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
            "Print".action.screenshot = {};
            "Ctrl+Print".action.screenshot-screen = {};
            "Alt+Print".action.screenshot-window = {};

            "Mod+Escape" = {
              allow-inhibiting = false;
              action.toggle-keyboard-shortcuts-inhibit = {};
            };

            "Mod+Shift+E" = ni {action.quit = {};};
            "Ctrl+Alt+Delete".action.quit = {};
            "Mod+Shift+P" = ni {action.power-off-monitors = {};};
          };
        };

        home.packages = lib.optionals (!config.noctalia-config.enable) (with pkgs; [
          hyprlock
        ]);

        services.swayidle = {
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
              command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
              resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
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
