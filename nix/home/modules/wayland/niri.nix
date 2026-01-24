{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./walker.nix
    ./waybar.nix
    ./swaybg.nix
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
            noctalia-shell ipc call lockScreen lock
          ''
        else
          pkgs.writeShellScript "lock-screen" ''
            ${pkgs.hyprlock}/bin/hyprlock &
          '';
    in
      lib.mkIf (config.wayland.enable && config.wayland.compositor == "niri") {
        # Enable walker and waybar by default when niri is enabled (unless noctalia is used)
        walker-config.enable = lib.mkDefault true;
        waybar-config.enable = lib.mkDefault (!config.noctalia-config.enable);
        swaybg-config.enable = lib.mkDefault (!config.noctalia-config.enable);

        programs.niri.settings = {
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
              max-scroll-amount = "90%";
            };
          };

          cursor = {
            theme = "Adwaita";
            size = 24;
          };

          outputs."eDP-1" = {
            mode = {
              width = 3840;
              height = 2160;
              refresh = 60.0;
            };
            scale = 2.0;
            transform = {
              rotation = 0;
              flipped = false;
            };
            position = {
              x = 1280;
              y = 0;
            };
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

          spawn-at-startup =
            [
              {command = ["elephant"];}
              {command = ["walker" "--gapplication-service"];}
            ]
            ++ (
              if config.noctalia-config.enable
              then [{command = ["noctalia-shell"];}]
              else [{command = ["swaybg" "-i" config.swaybg-config.selectedWallpaperPath "-m" "fill"];}]
            );

          prefer-no-csd = true;
          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

          hotkey-overlay.skip-at-startup = true;

          animations = {};

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
            launcherBind =
              if config.noctalia-config.enable
              then {action.spawn = noctalia "launcher toggle";}
              else {action.spawn = ["walker"];};

            lockBind =
              if config.noctalia-config.enable
              then {action.spawn = noctalia "lockScreen lock";}
              else {action.spawn = ["hyprlock"];};

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
            "Mod+Shift+Slash".action.show-hotkey-overlay = {};
            "Mod+Return".action.spawn = ["ghostty"];
            "Mod+D" = launcherBind;
            "Mod+E".action.spawn = ["nautilus"];
            "Mod+V".action.toggle-window-floating = {};
            "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = {};
            "Super+Alt+L" = lockBind;

            "Super+Alt+S" = {
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

            "Mod+O" = {
              repeat = false;
              action.toggle-overview = {};
            };
            "Mod+Q" = {
              repeat = false;
              action.close-window = {};
            };

            # Focus navigation
            "Mod+Left".action.focus-column-left = {};
            "Mod+Down".action.focus-window-down = {};
            "Mod+Up".action.focus-window-up = {};
            "Mod+Right".action.focus-column-right = {};
            "Mod+H".action.focus-column-left = {};
            "Mod+J".action.focus-window-down = {};
            "Mod+K".action.focus-window-up = {};
            "Mod+L".action.focus-column-right = {};

            # Move windows
            "Mod+Shift+Left".action.move-column-left = {};
            "Mod+Shift+Down".action.move-window-down = {};
            "Mod+Shift+Up".action.move-window-up = {};
            "Mod+Shift+Right".action.move-column-right = {};
            "Mod+Shift+H".action.move-column-left = {};
            "Mod+Shift+J".action.move-window-down = {};
            "Mod+Shift+K".action.move-window-up = {};
            "Mod+Shift+L".action.move-column-right = {};

            "Mod+Home".action.focus-column-first = {};
            "Mod+End".action.focus-column-last = {};
            "Mod+Ctrl+Home".action.move-column-to-first = {};
            "Mod+Ctrl+End".action.move-column-to-last = {};

            # Monitor navigation
            "Mod+Ctrl+H".action.focus-monitor-left = {};
            "Mod+Ctrl+J".action.focus-monitor-down = {};
            "Mod+Ctrl+K".action.focus-monitor-up = {};
            "Mod+Ctrl+L".action.focus-monitor-right = {};

            "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = {};
            "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = {};
            "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = {};
            "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = {};

            # Workspace navigation
            "Mod+Page_Down".action.focus-workspace-down = {};
            "Mod+Page_Up".action.focus-workspace-up = {};
            "Mod+U".action.focus-workspace-down = {};
            "Mod+I".action.focus-workspace-up = {};
            "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = {};
            "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = {};
            "Mod+Ctrl+U".action.move-column-to-workspace-down = {};
            "Mod+Ctrl+I".action.move-column-to-workspace-up = {};

            "Mod+Shift+Page_Down".action.move-workspace-down = {};
            "Mod+Shift+Page_Up".action.move-workspace-up = {};
            "Mod+Shift+U".action.move-workspace-down = {};
            "Mod+Shift+I".action.move-workspace-up = {};

            # Wheel scroll workspace switching
            "Mod+WheelScrollDown" = {
              cooldown-ms = 150;
              action.focus-workspace-down = {};
            };
            "Mod+WheelScrollUp" = {
              cooldown-ms = 150;
              action.focus-workspace-up = {};
            };
            "Mod+Ctrl+WheelScrollDown" = {
              cooldown-ms = 150;
              action.move-column-to-workspace-down = {};
            };
            "Mod+Ctrl+WheelScrollUp" = {
              cooldown-ms = 150;
              action.move-column-to-workspace-up = {};
            };

            # Wheel scroll column navigation
            "Mod+WheelScrollRight".action.focus-column-right = {};
            "Mod+WheelScrollLeft".action.focus-column-left = {};
            "Mod+Ctrl+WheelScrollRight".action.move-column-right = {};
            "Mod+Ctrl+WheelScrollLeft".action.move-column-left = {};

            "Mod+Shift+WheelScrollDown".action.focus-column-right = {};
            "Mod+Shift+WheelScrollUp".action.focus-column-left = {};
            "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = {};
            "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = {};

            # Workspace switching (1-10)
            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;
            "Mod+0".action.focus-workspace = 10;

            "Mod+Shift+1".action.move-column-to-workspace = 1;
            "Mod+Shift+2".action.move-column-to-workspace = 2;
            "Mod+Shift+3".action.move-column-to-workspace = 3;
            "Mod+Shift+4".action.move-column-to-workspace = 4;
            "Mod+Shift+5".action.move-column-to-workspace = 5;
            "Mod+Shift+6".action.move-column-to-workspace = 6;
            "Mod+Shift+7".action.move-column-to-workspace = 7;
            "Mod+Shift+8".action.move-column-to-workspace = 8;
            "Mod+Shift+9".action.move-column-to-workspace = 9;
            "Mod+Shift+0".action.move-column-to-workspace = 10;

            # Window management
            "Mod+BracketLeft".action.consume-or-expel-window-left = {};
            "Mod+BracketRight".action.consume-or-expel-window-right = {};
            "Mod+Comma".action.consume-window-into-column = {};
            "Mod+Period".action.expel-window-from-column = {};

            "Mod+R".action.switch-preset-column-width = {};
            "Mod+Shift+R".action.switch-preset-window-height = {};
            "Mod+Ctrl+R".action.reset-window-height = {};
            "Mod+F".action.maximize-column = {};
            "Mod+Shift+F".action.fullscreen-window = {};
            "Mod+Ctrl+F".action.expand-column-to-available-width = {};

            "Mod+C".action.center-column = {};
            "Mod+Ctrl+C".action.center-visible-columns = {};

            "Mod+Minus".action.set-column-width = "-10%";
            "Mod+Equal".action.set-column-width = "+10%";
            "Mod+Shift+Minus".action.set-window-height = "-10%";
            "Mod+Shift+Equal".action.set-window-height = "+10%";

            "Mod+W".action.toggle-column-tabbed-display = {};

            # Screenshots
            "Print".action.screenshot = {};
            "Ctrl+Print".action.screenshot-screen = {};
            "Alt+Print".action.screenshot-window = {};

            "Mod+Escape" = {
              allow-inhibiting = false;
              action.toggle-keyboard-shortcuts-inhibit = {};
            };

            "Mod+Shift+E".action.quit = {};
            "Ctrl+Alt+Delete".action.quit = {};
            "Mod+Shift+P".action.power-off-monitors = {};
          };
        };

        home.packages = lib.optionals (!config.noctalia-config.enable) (with pkgs; [
          hyprlock
        ]);
        programs.fuzzel.enable = true; # backup app launcher
        programs.satty.enable = true; # screenshot annotation

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
              command = "${pkgs.systemd}/bin/systemctl suspend";
            }
          ];
        };
      }
  );
}
