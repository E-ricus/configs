# DankMaterialShell (DMS) - Wayland desktop shell.
#
# Provides a full desktop shell experience: bar, notifications, wallpaper,
# lock screen, idle management, app launcher, clipboard manager, and more.
# Runs as a systemd user service for reliable start/restart.
#
# When enabled, DMS replaces:
# - mako (notifications)
# - swayidle (idle management, via built-in idle inhibitor + lock)
# - hyprlock (lock screen, via built-in session-lock)
# - swaybg / wallpaper tools (built-in wallpaper management)
# - brightnessctl scripts (built-in brightness control with OSD)
# - volume scripts (built-in audio control with OSD)
{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  jsonFormat = pkgs.formats.json {};

  # DMS session defaults enforced on every activation.
  # session.json is mutable (DMS writes wallpaper picks, mode toggles, etc.)
  # so we can't use home-manager's xdg.stateFile (that creates a read-only
  # nix-store symlink). Instead we merge our overrides on top of whatever
  # DMS has already written, preserving runtime state while ensuring our
  # declared values win.
  #
  sessionDefaults = {
    # -- Theme --
    isLightMode = false;

    # -- Wallpaper --
    wallpaperTransition = "fade";
    wallpaperFillMode = "Fill";

    # -- Do not disturb --
    doNotDisturb = false;

    # -- Misc --
    weatherHourlyDetailed = true;
  };

  sessionDefaultsJson = jsonFormat.generate "dms-session-defaults.json" sessionDefaults;
in {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.dms-plugin-registry.homeModules.default
  ];

  options = {
    dms-config.enable =
      lib.mkEnableOption "enables DankMaterialShell desktop shell";
  };

  config = lib.mkIf config.dms-config.enable {
    programs.dank-material-shell = {
      enable = true;

      # -- Systemd service --
      # Runs as a user service, auto-restarts on config change.
      # Niri has native systemd session integration so this binds correctly.
      # Do NOT combine with niri.enableSpawn (would spawn two instances).
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      # -- Niri integration --
      niri = {
        # Systemd handles startup, not spawn-at-startup
        enableSpawn = false;
        # We add keybinds manually in niri.nix to avoid conflicts
        # with existing compositor keybinds (Mod+V, Mod+Comma, etc.)
        enableKeybinds = false;
        # Use the includes hack: renames niri-flake config.kdl -> hm.kdl,
        # then creates a new config.kdl that includes hm.kdl + DMS files.
        # DMS auto-generates binds, colors, layout, alttab, outputs, wpblur.
        includes = {
          enable = true;
          override = true;
          originalFileName = "hm";
          filesToInclude = [
            "alttab"
            "binds"
            "colors"
            "cursor"
            "layout"
            "outputs"
            "wpblur"
          ];
        };
      };

      # -- Feature toggles --
      enableSystemMonitoring = true; # dgop for system resource widgets
      enableDynamicTheming = true; # matugen wallpaper-based color generation
      enableClipboardPaste = true; # wtype for pasting from clipboard manager
      enableAudioWavelength = true; # cava audio visualizer
      enableVPN = true; # VPN management widget

      settings = {
        theme = "dark";
        dynamicTheming = false;
        opacity = 1.0;

        # Detect location by IP
        useAutoLocation = true;

        # Dock: show in niri overview
        dockOpenOnOverview = true;

        # -- Compositing --
        blurredWallpaperLayer = false;
        blurWallpaperOnOverview = false;
        modalDarkenBackground = true;
        niriOverviewOverlayEnabled = true;

        # -- Animation --
        animationSpeed = 1;
        customAnimationDuration = 500;

        # -- Spotlight / launcher --
        appLauncherViewMode = "list";
        spotlightModalViewMode = "list";
        sortAppsAlphabetically = false;
        dankLauncherV2Size = "compact";
        dankLauncherV2BorderEnabled = false;
        dankLauncherV2ShowFooter = true;
        spotlightCloseNiriOverview = true;
        showThirdPartyPlugins = true;
        searchAppActions = true;

        # -- Theming --
        gtkThemingEnabled = true;
        qtThemingEnabled = true;

        barConfigs = [
          {
            id = "default";
            name = "Main Bar";
            enabled = true;
            position = 2; # 0 top, 1 down, 2 left, 3 right
            screenPreferences = ["all"];
            showOnLastDisplay = true;
            leftWidgets = ["workspaceSwitcher" "focusedWindow" "catWidget"];
            centerWidgets = ["music" "clock" "privacyIndicator"];
            rightWidgets = ["systemTray" "vpn" "clipboard" "cpuUsage" "memUsage" "battery" "controlCenterButton" "notificationButton"];
            spacing = 3;
            innerPadding = 3;
            bottomGap = 0;
            transparency = 1.0;
            widgetTransparency = 1.0;
            squareCorners = false;
            noBackground = false;
            maximizeWidgetIcons = false;
            maximizeWidgetText = false;
            removeWidgetPadding = false;
            widgetPadding = 6;
            gothCornersEnabled = false;
            gothCornerRadiusOverride = false;
            gothCornerRadiusValue = 12;
            borderEnabled = false;
            borderColor = "surfaceText";
            borderOpacity = 1.0;
            borderThickness = 1;
            widgetOutlineEnabled = false;
            widgetOutlineColor = "primary";
            widgetOutlineOpacity = 1.0;
            widgetOutlineThickness = 1;
            fontScale = 0.9;
            iconScale = 0.9;
            autoHide = false;
            autoHideDelay = 250;
            showOnWindowsOpen = false;
            openOnOverview = false;
            visible = true;
            popupGapsAuto = true;
            popupGapsManual = 4;
            maximizeDetection = true;
            scrollEnabled = true;
            scrollXBehavior = "column";
            scrollYBehavior = "workspace";
            shadowIntensity = 0;
            shadowOpacity = 60;
            shadowColorMode = "text";
            shadowCustomColor = "#000000";
            clickThrough = false;
          }
        ];

        # -- Fingerprint --
        enableFprint = true;
        greeterEnableFprint = true;

        # -- Idle / lock / suspend --
        # AC power (seconds, 0 = disabled)
        acLockTimeout = 300; # 5 min -> lock
        acMonitorTimeout = 600; # 10 min -> DPMS off
        acSuspendTimeout = 1800; # 30 min -> suspend
        acSuspendBehavior = 0; # 0=suspend, 1=hibernate, 2=suspend-then-hibernate

        # Battery power
        batteryLockTimeout = 180; # 3 min -> lock
        batteryMonitorTimeout = 300; # 5 min -> DPMS off
        batterySuspendTimeout = 900; # 15 min -> suspend
        batterySuspendBehavior = 2; # 0=suspend, 1=hibernate, 2=suspend-then-hibernate

        lockBeforeSuspend = true;
        loginctlLockIntegration = true;
      };

      # -- Clipboard --
      clipboardSettings = {
        maxHistory = 25;
        clearAtStartup = false;
        disabled = false;
      };

      # -- Plugins --
      plugins = {
        dankBatteryAlerts.enable = true;
        catWidget.enable = true;

        # Launcher / spotlight plugins
        commandRunner.enable = true;
        calculator.enable = true;
        webSearch = {
          enable = true;
          settings = {
            defaultEngine = "kagi";
          };
        };
        emojiLauncher = {
          enable = true;
          settings = {
            noTrigger = false;
            trigger = ":";
          };
        };
        sessionPower.enable = true;
      };
    };

    # Screenshot editors for DMS niri screenshot integration
    home.packages = with pkgs; [
      qt6Packages.qtmultimedia
      swappy
      satty
    ];

    # Seed empty DMS niri include files so niri doesn't error on startup
    # before DMS has had a chance to generate them. DMS overwrites these
    # at runtime with real content.
    #
    # Merge session defaults into session.json (mutable). jq merges our
    # declared values on top of the existing file, so runtime state like
    # wallpaper picks and pinned apps are preserved while weather location,
    # theme mode, etc. are always set to our declared values.
    home.activation.seedDmsState = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.config/niri/dms"
      for f in alttab colors layout outputs wpblur binds cursor windowrules; do
        [ -f "$HOME/.config/niri/dms/$f.kdl" ] || touch "$HOME/.config/niri/dms/$f.kdl"
      done

      SESSION="$HOME/.local/state/DankMaterialShell/session.json"
      mkdir -p "$(dirname "$SESSION")"
      if [ -f "$SESSION" ]; then
        # Merge: existing session * our overrides (our values win)
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$SESSION" ${sessionDefaultsJson} > "$SESSION.tmp" \
          && mv "$SESSION.tmp" "$SESSION"
      else
        cp ${sessionDefaultsJson} "$SESSION"
        chmod 644 "$SESSION"
      fi
    '';

    # DMS handles notifications natively - disable mako
    services.mako.enable = lib.mkForce false;
  };
}
