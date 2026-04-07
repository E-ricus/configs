# All niri wrapper modules — common + per-variant settings.
# All entries live here in one block so flake-parts can expose them as a single
# flake.wrappersModules attrset without merge conflicts.
{self, ...}: {
  flake.wrappersModules = {
    # ── Shared: layout, keybinds, env, window-rules ──────────────────
    niri-common = {
      lib,
      pkgs,
      ...
    }: let
      # ── Helpers: wrap every bind with allow-inhibiting = false ──────
      # ni:  simple action, no arguments  (e.g. focus-column-left)
      ni = action: _: {
        props.allow-inhibiting = false;
        content.${action} = _: {};
      };
      # niv: action with a value argument (e.g. focus-workspace = 1)
      niv = action: value: _: {
        props.allow-inhibiting = false;
        content.${action} = value;
      };
      # nip: action with extra props      (e.g. cooldown-ms = 150)
      nip = extraProps: action: _: {
        props = {allow-inhibiting = false;} // extraProps;
        content.${action} = _: {};
      };
    in {
      v2-settings = true;

      env = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        QT_WAYLAND_RECONNECT = "1";
        XCURSOR_THEME = "Adwaita";
        XCURSOR_SIZE = "24";
      };
      settings = {
        input = {
          keyboard.xkb = {
            layout = "us";
            options = "compose:ralt";
          };
          touchpad = {
            tap = _: {};
            natural-scroll = _: {};
          };
          # focus-follows-mouse is disabled by default (omitted).
          # To enable, add in a variant:
          #   focus-follows-mouse = _: { props.max-scroll-amount = "90%"; };
        };

        gestures.hot-corners.off = _: {};

        layout = {
          gaps = 8;
          center-focused-column = "never";
          preset-column-widths = [
            {proportion = 0.33333;}
            {proportion = 0.5;}
            {proportion = 0.66667;}
          ];
          default-column-width = {proportion = 0.5;};
          # Catppuccin Mocha colors
          focus-ring = {
            width = 4;
            active-color = "#b4befe"; # Lavender
            inactive-color = "#6c7086"; # Overlay0
          };
          border = {
            off = _: {};
            width = 4;
            active-color = "#b4befe"; # Lavender
            inactive-color = "#6c7086"; # Overlay0
          };
        };

        workspaces = {
          "1" = _: {};
          "2" = _: {};
          "3" = _: {};
          "4" = _: {};
          "5" = _: {};
        };

        prefer-no-csd = _: {};
        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
        hotkey-overlay.skip-at-startup = _: {};
        overview.backdrop-color = "#1e1e2e"; # Catppuccin Mocha Base

        environment = {
        };

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

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
            geometry-corner-radius = _: {
              props = [8.0 8.0 8.0 8.0];
            };
            clip-to-geometry = true;
          }
        ];

        # ── Common keybinds ─────────────────────────────────────────────
        # All binds use the ni / niv / nip helpers defined above so that
        # every keybinding carries  allow-inhibiting = false  and keeps
        # working even when a client (e.g. a VM) activates the Wayland
        # keyboard-shortcuts-inhibit protocol.
        binds = {
          # Hotkey overlay
          "Mod+Shift+Slash" = ni "show-hotkey-overlay";

          # Terminal
          "Mod+Return" = _: {
            props.allow-inhibiting = false;
            content.spawn = [(lib.getExe pkgs.ghostty)];
          };

          # Fuzzel fallback launcher (DMS/Noctalia override Mod+D)
          "Mod+Shift+D" = _: {
            props.allow-inhibiting = false;
            content.spawn = [(lib.getExe pkgs.fuzzel)];
          };

          # File manager
          "Mod+E" = _: {
            props.allow-inhibiting = false;
            content.spawn = [(lib.getExe pkgs.nautilus)];
          };

          # Floating / tiling
          "Mod+T" = ni "toggle-window-floating";
          "Mod+Shift+V" = ni "switch-focus-between-floating-and-tiling";

          # Screen reader toggle
          "Super+Alt+S" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn-sh = "pkill orca || exec orca";
          };

          # Overview
          "Mod+O" = _: {
            props.allow-inhibiting = false;
            props.repeat = false;
            content.toggle-overview = _: {};
          };

          # Close window
          "Mod+Q" = _: {
            props.allow-inhibiting = false;
            props.repeat = false;
            content.close-window = _: {};
          };

          # ── Focus navigation ──────────────────────────────────────────
          "Mod+Left" = ni "focus-column-left";
          "Mod+Down" = ni "focus-window-down";
          "Mod+Up" = ni "focus-window-up";
          "Mod+Right" = ni "focus-column-right";
          "Mod+H" = ni "focus-column-left";
          "Mod+J" = ni "focus-window-down";
          "Mod+K" = ni "focus-window-up";
          "Mod+L" = ni "focus-column-right";

          # ── Move windows ──────────────────────────────────────────────
          "Mod+Shift+Left" = ni "move-column-left";
          "Mod+Shift+Down" = ni "move-window-down";
          "Mod+Shift+Up" = ni "move-window-up";
          "Mod+Shift+Right" = ni "move-column-right";
          "Mod+Shift+H" = ni "move-column-left";
          "Mod+Shift+J" = ni "move-window-down";
          "Mod+Shift+K" = ni "move-window-up";
          "Mod+Shift+L" = ni "move-column-right";

          "Mod+Home" = ni "focus-column-first";
          "Mod+End" = ni "focus-column-last";
          "Mod+Ctrl+Home" = ni "move-column-to-first";
          "Mod+Ctrl+End" = ni "move-column-to-last";

          # ── Monitor navigation ────────────────────────────────────────
          "Mod+Ctrl+H" = ni "focus-monitor-left";
          "Mod+Ctrl+J" = ni "focus-monitor-down";
          "Mod+Ctrl+K" = ni "focus-monitor-up";
          "Mod+Ctrl+L" = ni "focus-monitor-right";

          "Mod+Shift+Ctrl+H" = ni "move-column-to-monitor-left";
          "Mod+Shift+Ctrl+J" = ni "move-column-to-monitor-down";
          "Mod+Shift+Ctrl+K" = ni "move-column-to-monitor-up";
          "Mod+Shift+Ctrl+L" = ni "move-column-to-monitor-right";

          # ── Workspace navigation ──────────────────────────────────────
          "Mod+Page_Down" = ni "focus-workspace-down";
          "Mod+Page_Up" = ni "focus-workspace-up";
          "Mod+U" = ni "focus-workspace-down";
          "Mod+I" = ni "focus-workspace-up";
          "Mod+Ctrl+Page_Down" = ni "move-column-to-workspace-down";
          "Mod+Ctrl+Page_Up" = ni "move-column-to-workspace-up";
          "Mod+Ctrl+U" = ni "move-column-to-workspace-down";
          "Mod+Ctrl+I" = ni "move-column-to-workspace-up";

          "Mod+Shift+Page_Down" = ni "move-workspace-down";
          "Mod+Shift+Page_Up" = ni "move-workspace-up";
          "Mod+Shift+U" = ni "move-workspace-down";
          "Mod+Shift+I" = ni "move-workspace-up";

          # ── Wheel scroll ──────────────────────────────────────────────
          "Mod+WheelScrollDown" = nip {cooldown-ms = 150;} "focus-workspace-down";
          "Mod+WheelScrollUp" = nip {cooldown-ms = 150;} "focus-workspace-up";
          "Mod+Ctrl+WheelScrollDown" = nip {cooldown-ms = 150;} "move-column-to-workspace-down";
          "Mod+Ctrl+WheelScrollUp" = nip {cooldown-ms = 150;} "move-column-to-workspace-up";

          "Mod+WheelScrollRight" = ni "focus-column-right";
          "Mod+WheelScrollLeft" = ni "focus-column-left";
          "Mod+Ctrl+WheelScrollRight" = ni "move-column-right";
          "Mod+Ctrl+WheelScrollLeft" = ni "move-column-left";

          "Mod+Shift+WheelScrollDown" = ni "focus-column-right";
          "Mod+Shift+WheelScrollUp" = ni "focus-column-left";
          "Mod+Ctrl+Shift+WheelScrollDown" = ni "move-column-right";
          "Mod+Ctrl+Shift+WheelScrollUp" = ni "move-column-left";

          # ── Workspace switching (1-10) ────────────────────────────────
          "Mod+1" = niv "focus-workspace" 1;
          "Mod+2" = niv "focus-workspace" 2;
          "Mod+3" = niv "focus-workspace" 3;
          "Mod+4" = niv "focus-workspace" 4;
          "Mod+5" = niv "focus-workspace" 5;
          "Mod+6" = niv "focus-workspace" 6;
          "Mod+7" = niv "focus-workspace" 7;
          "Mod+8" = niv "focus-workspace" 8;
          "Mod+9" = niv "focus-workspace" 9;
          "Mod+0" = niv "focus-workspace" 10;

          "Mod+Shift+1" = niv "move-column-to-workspace" 1;
          "Mod+Shift+2" = niv "move-column-to-workspace" 2;
          "Mod+Shift+3" = niv "move-column-to-workspace" 3;
          "Mod+Shift+4" = niv "move-column-to-workspace" 4;
          "Mod+Shift+5" = niv "move-column-to-workspace" 5;
          "Mod+Shift+6" = niv "move-column-to-workspace" 6;
          "Mod+Shift+7" = niv "move-column-to-workspace" 7;
          "Mod+Shift+8" = niv "move-column-to-workspace" 8;
          "Mod+Shift+9" = niv "move-column-to-workspace" 9;
          "Mod+Shift+0" = niv "move-column-to-workspace" 10;

          # ── Window management ─────────────────────────────────────────
          "Mod+BracketLeft" = ni "consume-or-expel-window-left";
          "Mod+BracketRight" = ni "consume-or-expel-window-right";
          "Mod+Comma" = ni "consume-window-into-column";
          "Mod+Period" = ni "expel-window-from-column";

          "Mod+R" = ni "switch-preset-column-width";
          "Mod+Shift+R" = ni "switch-preset-window-height";
          "Mod+Ctrl+R" = ni "reset-window-height";
          "Mod+F" = ni "maximize-column";
          "Mod+Shift+F" = ni "fullscreen-window";
          "Mod+Ctrl+F" = ni "expand-column-to-available-width";

          "Mod+C" = ni "center-column";
          "Mod+Ctrl+C" = ni "center-visible-columns";

          "Mod+Minus" = niv "set-column-width" "-10%";
          "Mod+Equal" = niv "set-column-width" "+10%";
          "Mod+Shift+Minus" = niv "set-window-height" "-10%";
          "Mod+Shift+Equal" = niv "set-window-height" "+10%";

          "Mod+W" = ni "toggle-column-tabbed-display";

          # ── Screenshots niri builtin ──────────────────────────────────
          "Print" = ni "screenshot";
          "Ctrl+Print" = ni "screenshot-screen";
          "Alt+Print" = ni "screenshot-window";

          # ── Session ───────────────────────────────────────────────────
          "Mod+Escape" = ni "toggle-keyboard-shortcuts-inhibit";

          "Mod+Shift+E" = ni "quit";
          "Ctrl+Alt+Delete" = ni "quit";
          "Mod+Shift+P" = ni "power-off-monitors";
        };
      };
    };

    # ── Noctalia-specific settings ────────────────────────────────────
    niri-noctalia = {
      lib,
      pkgs,
      ...
    }: let
      noctaliaExe = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      noctalia = cmd: [noctaliaExe "ipc" "call"] ++ (lib.splitString " " cmd);
      brightnessScript =
        pkgs.writeShellScript "brightness-control"
        (builtins.readFile ../wayland/brightness-control.sh);
    in {
      v2-settings = true;
      env.NOCTALIA_PAM_SERVICE = "noctalia";
      settings = {
        layout.background-color = "transparent";
        spawn-at-startup = [noctaliaExe];
        binds = {
          "Mod+D" = _: {
            props.allow-inhibiting = false;
            content.spawn = noctalia "launcher toggle";
          };
          "Super+Alt+L" = _: {
            props.allow-inhibiting = false;
            content.spawn = noctalia "lockScreen lock";
          };
          "XF86AudioRaiseVolume" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = noctalia "volume increase";
          };
          "XF86AudioLowerVolume" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = noctalia "volume decrease";
          };
          "XF86AudioMute" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = noctalia "volume muteOutput";
          };
          "XF86AudioMicMute" = _: {
            props.allow-inhibiting = false;
            content.spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          };
          "XF86MonBrightnessUp" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = ["${brightnessScript}" "raise"];
          };
          "XF86MonBrightnessDown" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = ["${brightnessScript}" "lower"];
          };
          "XF86AudioPlay" = _: {
            props.allow-inhibiting = false;
            content.spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";
          };
          "XF86AudioStop" = _: {
            props.allow-inhibiting = false;
            content.spawn-sh = "${lib.getExe pkgs.playerctl} stop";
          };
          "XF86AudioPrev" = _: {
            props.allow-inhibiting = false;
            content.spawn-sh = "${lib.getExe pkgs.playerctl} previous";
          };
          "XF86AudioNext" = _: {
            props.allow-inhibiting = false;
            content.spawn-sh = "${lib.getExe pkgs.playerctl} next";
          };
        };
      };
    };

    # ── DMS-specific settings ─────────────────────────────────────────
    niri-dms = {
      lib,
      pkgs,
      ...
    }: let
      dms = cmd: ["dms" "ipc" "call"] ++ (lib.splitString " " cmd);
    in {
      v2-settings = true;
      settings = {
        layout.background-color = "transparent";
        layer-rules = [
          {
            matches = [{namespace = "^quickshell$";}];
            place-within-backdrop = true;
          }
          {
            matches = [{namespace = "dms:blurwallpaper";}];
            place-within-backdrop = true;
          }
          {
            matches = [{namespace = "^dms:clipboard$";}];
            block-out-from = "screencast";
          }
          {
            matches = [{namespace = "^dms:polkit$";}];
            block-out-from = "screencast";
          }
          {
            matches = [{namespace = "^dms:wifi-password$";}];
            block-out-from = "screencast";
          }
          {
            matches = [
              {namespace = "^dms:bar$";}
              {namespace = "^dms:dock$";}
            ];
            shadow = {
              on = _: {};
              softness = 40;
              spread = 5;
              offset = _: {
                props = {
                  x = 0;
                  y = 5;
                };
              };
              draw-behind-window = true;
              color = "#00000064";
            };
          }
        ];
        window-rules = [
          {
            matches = [{app-id = "^org\\.quickshell$";}];
            open-floating = true;
          }
        ];
        binds = {
          "Mod+D" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "spotlight toggle";
          };
          "Super+Alt+L" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "lock lock";
          };
          "XF86AudioRaiseVolume" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "audio increment 3";
          };
          "XF86AudioLowerVolume" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "audio decrement 3";
          };
          "XF86AudioMute" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "audio mute";
          };
          "XF86AudioMicMute" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "audio micmute";
          };
          "XF86MonBrightnessUp" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "brightness increment 5 ";
          };
          "XF86MonBrightnessDown" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "brightness decrement 5 ";
          };
          "XF86AudioPlay" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "mpris playPause";
          };
          "XF86AudioStop" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "mpris stop";
          };
          "XF86AudioPrev" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "mpris previous";
          };
          "XF86AudioNext" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "mpris next";
          };
          "Print" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "niri screenshot";
          };
          "Mod+Space" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "spotlight toggle";
          };
          "Mod+V" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "clipboard toggle";
          };
          "Mod+N" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "notifications toggle";
          };
          "Mod+M" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "processlist focusOrToggle";
          };
          "Mod+Shift+Comma" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "settings focusOrToggle";
          };
          "Mod+X" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "powermenu toggle";
          };
          "Mod+Y" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "dankdash wallpaper";
          };
          "Mod+Alt+N" = _: {
            props.allow-inhibiting = false;
            props.allow-when-locked = true;
            content.spawn = dms "night toggle";
          };
        };
      };
    };
  };
}
