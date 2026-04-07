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
  }: {
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
      binds = {
        # Hotkey overlay
        "Mod+Shift+Slash" = _: {
          props.allow-inhibiting = false;
          content.show-hotkey-overlay = _: {};
        };

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
        "Mod+T" = _: {
          props.allow-inhibiting = false;
          content.toggle-window-floating = _: {};
        };
        "Mod+Shift+V" = _: {
          props.allow-inhibiting = false;
          content.switch-focus-between-floating-and-tiling = _: {};
        };

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
        "Mod+Left".focus-column-left = _: {};
        "Mod+Down".focus-window-down = _: {};
        "Mod+Up".focus-window-up = _: {};
        "Mod+Right".focus-column-right = _: {};
        "Mod+H".focus-column-left = _: {};
        "Mod+J".focus-window-down = _: {};
        "Mod+K".focus-window-up = _: {};
        "Mod+L".focus-column-right = _: {};

        # ── Move windows ──────────────────────────────────────────────
        "Mod+Shift+Left".move-column-left = _: {};
        "Mod+Shift+Down".move-window-down = _: {};
        "Mod+Shift+Up".move-window-up = _: {};
        "Mod+Shift+Right".move-column-right = _: {};
        "Mod+Shift+H".move-column-left = _: {};
        "Mod+Shift+J".move-window-down = _: {};
        "Mod+Shift+K".move-window-up = _: {};
        "Mod+Shift+L".move-column-right = _: {};

        "Mod+Home".focus-column-first = _: {};
        "Mod+End".focus-column-last = _: {};
        "Mod+Ctrl+Home".move-column-to-first = _: {};
        "Mod+Ctrl+End".move-column-to-last = _: {};

        # ── Monitor navigation ────────────────────────────────────────
        "Mod+Ctrl+H".focus-monitor-left = _: {};
        "Mod+Ctrl+J".focus-monitor-down = _: {};
        "Mod+Ctrl+K".focus-monitor-up = _: {};
        "Mod+Ctrl+L".focus-monitor-right = _: {};

        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = _: {};
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = _: {};
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = _: {};
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = _: {};

        # ── Workspace navigation ──────────────────────────────────────
        "Mod+Page_Down".focus-workspace-down = _: {};
        "Mod+Page_Up".focus-workspace-up = _: {};
        "Mod+U".focus-workspace-down = _: {};
        "Mod+I".focus-workspace-up = _: {};
        "Mod+Ctrl+Page_Down".move-column-to-workspace-down = _: {};
        "Mod+Ctrl+Page_Up".move-column-to-workspace-up = _: {};
        "Mod+Ctrl+U".move-column-to-workspace-down = _: {};
        "Mod+Ctrl+I".move-column-to-workspace-up = _: {};

        "Mod+Shift+Page_Down".move-workspace-down = _: {};
        "Mod+Shift+Page_Up".move-workspace-up = _: {};
        "Mod+Shift+U".move-workspace-down = _: {};
        "Mod+Shift+I".move-workspace-up = _: {};

        # ── Wheel scroll ──────────────────────────────────────────────
        "Mod+WheelScrollDown" = _: {
          props.cooldown-ms = 150;
          content.focus-workspace-down = _: {};
        };
        "Mod+WheelScrollUp" = _: {
          props.cooldown-ms = 150;
          content.focus-workspace-up = _: {};
        };
        "Mod+Ctrl+WheelScrollDown" = _: {
          props.cooldown-ms = 150;
          content.move-column-to-workspace-down = _: {};
        };
        "Mod+Ctrl+WheelScrollUp" = _: {
          props.cooldown-ms = 150;
          content.move-column-to-workspace-up = _: {};
        };

        "Mod+WheelScrollRight".focus-column-right = _: {};
        "Mod+WheelScrollLeft".focus-column-left = _: {};
        "Mod+Ctrl+WheelScrollRight".move-column-right = _: {};
        "Mod+Ctrl+WheelScrollLeft".move-column-left = _: {};

        "Mod+Shift+WheelScrollDown".focus-column-right = _: {};
        "Mod+Shift+WheelScrollUp".focus-column-left = _: {};
        "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = _: {};
        "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = _: {};

        # ── Workspace switching (1-10) ────────────────────────────────
        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;
        "Mod+0".focus-workspace = 10;

        "Mod+Shift+1".move-column-to-workspace = 1;
        "Mod+Shift+2".move-column-to-workspace = 2;
        "Mod+Shift+3".move-column-to-workspace = 3;
        "Mod+Shift+4".move-column-to-workspace = 4;
        "Mod+Shift+5".move-column-to-workspace = 5;
        "Mod+Shift+6".move-column-to-workspace = 6;
        "Mod+Shift+7".move-column-to-workspace = 7;
        "Mod+Shift+8".move-column-to-workspace = 8;
        "Mod+Shift+9".move-column-to-workspace = 9;
        "Mod+Shift+0".move-column-to-workspace = 10;

        # ── Window management ─────────────────────────────────────────
        "Mod+BracketLeft".consume-or-expel-window-left = _: {};
        "Mod+BracketRight".consume-or-expel-window-right = _: {};
        "Mod+Comma".consume-window-into-column = _: {};
        "Mod+Period".expel-window-from-column = _: {};

        "Mod+R".switch-preset-column-width = _: {};
        "Mod+Shift+R".switch-preset-window-height = _: {};
        "Mod+Ctrl+R".reset-window-height = _: {};
        "Mod+F".maximize-column = _: {};
        "Mod+Shift+F".fullscreen-window = _: {};
        "Mod+Ctrl+F".expand-column-to-available-width = _: {};

        "Mod+C".center-column = _: {};
        "Mod+Ctrl+C".center-visible-columns = _: {};

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+W".toggle-column-tabbed-display = _: {};

        # ── Screenshots niri builtin ──────────────────────────────────

        "Print".screenshot = _: {};
        "Ctrl+Print".screenshot-screen = _: {};
        "Alt+Print".screenshot-window = _: {};

        # ── Session ───────────────────────────────────────────────────
        "Mod+Escape" = _: {
          props.allow-inhibiting = false;
          content.toggle-keyboard-shortcuts-inhibit = _: {};
        };

        "Mod+Shift+E".quit = _: {};
        "Ctrl+Alt+Delete".quit = _: {};
        "Mod+Shift+P".power-off-monitors = _: {};
      };
    };
  };

  # ── Noctalia-specific settings ────────────────────────────────────
  niri-noctalia = {lib, pkgs, ...}: let
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
          props.allow-when-locked = true;
          content.spawn = noctalia "volume increase";
        };
        "XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = noctalia "volume decrease";
        };
        "XF86AudioMute" = _: {
          props.allow-when-locked = true;
          content.spawn = noctalia "volume muteOutput";
        };
        "XF86AudioMicMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = _: {
          props.allow-when-locked = true;
          content.spawn = ["${brightnessScript}" "raise"];
        };
        "XF86MonBrightnessDown" = _: {
          props.allow-when-locked = true;
          content.spawn = ["${brightnessScript}" "lower"];
        };
        "XF86AudioPlay".spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";
        "XF86AudioStop".spawn-sh = "${lib.getExe pkgs.playerctl} stop";
        "XF86AudioPrev".spawn-sh = "${lib.getExe pkgs.playerctl} previous";
        "XF86AudioNext".spawn-sh = "${lib.getExe pkgs.playerctl} next";
      };
    };
  };

  # ── DMS-specific settings ─────────────────────────────────────────
  niri-dms = {lib, pkgs, ...}: let
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
            offset = _: {props = {x = 0; y = 5;};};
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
          props.allow-when-locked = true;
          content.spawn = dms "audio increment 3";
        };
        "XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "audio decrement 3";
        };
        "XF86AudioMute" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "audio mute";
        };
        "XF86AudioMicMute" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "audio micmute";
        };
        "XF86MonBrightnessUp" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "brightness increment 5 ";
        };
        "XF86MonBrightnessDown" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "brightness decrement 5 ";
        };
        "XF86AudioPlay" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "mpris playPause";
        };
        "XF86AudioStop" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "mpris stop";
        };
        "XF86AudioPrev" = _: {
          props.allow-when-locked = true;
          content.spawn = dms "mpris previous";
        };
        "XF86AudioNext" = _: {
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

  }; # end flake.wrappersModules
}
