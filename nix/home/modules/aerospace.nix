{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    aerospace-config.enable =
      lib.mkEnableOption "enables aerospace window manager configuration";
  };

  config = lib.mkIf config.aerospace-config.enable {
    programs.aerospace = {
      enable = true;

      userSettings = {
        # Startup and login
        start-at-login = true;
        after-login-command = [];
        after-startup-command = [];

        # Normalizations
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        # Layout
        accordion-padding = 30;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";

        # Key mapping
        key-mapping.preset = "qwerty";

        # Mouse behavior
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-focus-changed = "move-mouse window-lazy-center";

        # Gaps
        gaps = {
          inner = {
            horizontal = 7;
            vertical = 7;
          };
          outer = {
            left = 7;
            bottom = 7;
            top = 7;
            right = 7;
          };
        };

        # Main mode keybindings
        mode.main.binding = {
          # Layout
          cmd-alt-slash = "layout tiles horizontal vertical";
          cmd-alt-comma = "layout accordion horizontal vertical";

          # Focus
          cmd-alt-h = "focus left";
          cmd-alt-j = "focus down";
          cmd-alt-k = "focus up";
          cmd-alt-l = "focus right";

          # Move
          cmd-alt-shift-h = "move left";
          cmd-alt-shift-j = "move down";
          cmd-alt-shift-k = "move up";
          cmd-alt-shift-l = "move right";

          # Workspaces
          cmd-alt-1 = "workspace 1";
          cmd-alt-2 = "workspace 2";
          cmd-alt-3 = "workspace 3";
          cmd-alt-4 = "workspace 4";
          cmd-alt-5 = "workspace 5";
          cmd-alt-6 = "workspace 6";
          cmd-alt-7 = "workspace 7";
          cmd-alt-8 = "workspace 8";
          cmd-alt-9 = "workspace 9";
          cmd-alt-b = "workspace B";
          cmd-alt-d = "workspace D";
          cmd-alt-m = "workspace M";
          cmd-alt-p = "workspace P";
          cmd-alt-t = "workspace T";
          cmd-alt-w = "workspace W";
          cmd-alt-z = "workspace Z";

          # Move to workspace
          cmd-alt-shift-1 = "move-node-to-workspace 1";
          cmd-alt-shift-2 = "move-node-to-workspace 2";
          cmd-alt-shift-3 = "move-node-to-workspace 3";
          cmd-alt-shift-4 = "move-node-to-workspace 4";
          cmd-alt-shift-5 = "move-node-to-workspace 5";
          cmd-alt-shift-6 = "move-node-to-workspace 6";
          cmd-alt-shift-7 = "move-node-to-workspace 7";
          cmd-alt-shift-8 = "move-node-to-workspace 8";
          cmd-alt-shift-9 = "move-node-to-workspace 9";
          cmd-alt-shift-b = "move-node-to-workspace B";
          cmd-alt-shift-d = "move-node-to-workspace D";
          cmd-alt-shift-m = "move-node-to-workspace M";
          cmd-alt-shift-p = "move-node-to-workspace P";
          cmd-alt-shift-t = "move-node-to-workspace T";
          cmd-alt-shift-w = "move-node-to-workspace W";
          cmd-alt-shift-z = "move-node-to-workspace Z";

          # Fullscreen
          cmd-alt-shift-f = "fullscreen";

          # Workspace navigation
          cmd-alt-tab = "workspace-back-and-forth";
          cmd-alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          # Modes
          cmd-alt-shift-semicolon = "mode service";
          cmd-alt-shift-r = "mode resize";
        };

        # Resize mode
        mode.resize.binding = {
          h = "resize width -50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width +50";
          b = "balance-sizes";
          minus = "resize smart -50";
          equal = "resize smart +50";
          enter = "mode main";
          esc = "mode main";
        };

        # Service mode
        mode.service.binding = {
          esc = ["reload-config" "mode main"];
          r = ["flatten-workspace-tree" "mode main"];
          f = ["layout floating tiling" "mode main"];
          backspace = ["close-all-windows-but-current" "mode main"];
          cmd-alt-shift-h = ["join-with left" "mode main"];
          cmd-alt-shift-j = ["join-with down" "mode main"];
          cmd-alt-shift-k = ["join-with up" "mode main"];
          cmd-alt-shift-l = ["join-with right" "mode main"];
        };

        # Window detection rules
        on-window-detected = [
          {
            "if".app-id = "com.github.wez.wezterm";
            run = "move-node-to-workspace T";
          }
          {
            "if".app-id = "at.eggerapps.Postico";
            run = "move-node-to-workspace D";
          }
          {
            "if".app-id = " com.tinyapp.TablePlus";
            run = "move-node-to-workspace D";
          }
          {
            "if".app-id = "net.whatsapp.WhatsApp";
            run = "move-node-to-workspace W";
          }
          {
            "if".app-id = "com.brave.Browser";
            run = "move-node-to-workspace P";
          }
          {
            "if".app-id = "com.google.Chorme";
            run = "move-node-to-workspace B";
          }
          {
            "if".app-id = "dev.zed.Zed";
            run = "move-node-to-workspace Z";
          }
          {
            "if".app-id = "com.mitchellh.ghostty";
            run = ["layout floating"];
          }
          {
            "if".app-id = "com.mitchellh.ghostty";
            run = "move-node-to-workspace T";
          }
          {
            "if".app-id = "com.mitchellh.ghostty";
            run = "move-node-to-workspace T";
          }
        ];
      };
    };
  };
}
