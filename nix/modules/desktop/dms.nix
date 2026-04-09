# DankMaterialShell (DMS) — Wayland desktop shell.
# Provides bar, notifications, wallpaper, lock screen, idle management, and more.
{
  den,
  inputs,
  ...
}: let
  dmsGreeterModule = inputs.dms.nixosModules.greeter;
  dmsHmModule = inputs.dms.homeModules.dank-material-shell;
  # DMS niri integration disabled — requires niri flake's HM module (config.lib.niri.actions)
  # TODO: re-enable once DMS supports wrapped niri or drops the niri flake dependency
  # dmsNiriHmModule = inputs.dms.homeModules.niri;
  dmsPluginModule = inputs.dms-plugin-registry.homeModules.default;
in {
  den.aspects.dms = {
    includes = [den.aspects.wayland];

    # NixOS: DankGreeter (replaces ReGreet when DMS is active)
    nixos = {...}: {
      imports = [dmsGreeterModule];
      programs.dank-material-shell.greeter = {
        enable = true;
        # Compositor name is read from the niri/hyprland aspect that's also included
        compositor.name = "niri";
        configHome = "/home/ericus";
      };
    };

    homeManager = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        dmsHmModule
        dmsPluginModule
      ];

      programs.dank-material-shell = {
        enable = true;

        systemd = {
          enable = true;
          restartIfChanged = true;
        };

        enableSystemMonitoring = true;
        enableDynamicTheming = true;
        enableClipboardPaste = true;
        enableAudioWavelength = true;
        enableVPN = true;

        settings = {
          theme = "dark";
          dynamicTheming = false;
          opacity = 1.0;
          useAutoLocation = true;
          dockOpenOnOverview = true;
          blurredWallpaperLayer = false;
          blurWallpaperOnOverview = false;
          niriOverviewOverlayEnabled = true;
          modalDarkenBackground = true;
          animationSpeed = 1;
          customAnimationDuration = 500;
          appLauncherViewMode = "list";
          spotlightModalViewMode = "list";
          sortAppsAlphabetically = false;
          dankLauncherV2Size = "compact";
          dankLauncherV2BorderEnabled = false;
          dankLauncherV2ShowFooter = true;
          spotlightCloseNiriOverview = true;
          showThirdPartyPlugins = true;
          searchAppActions = true;
          gtkThemingEnabled = true;
          qtThemingEnabled = true;

          barConfigs = [
            {
              id = "default";
              name = "Main Bar";
              enabled = true;
              position = 0;
              screenPreferences = ["all"];
              showOnLastDisplay = true;
              leftWidgets = ["powerMenuButton" "workspaceSwitcher" "focusedWindow" "catWidget"];
              centerWidgets = ["music" "clock" "privacyIndicator"];
              rightWidgets = ["systemTray" "separator" "screenRecorder" "vpn" "cpuUsage" "memUsage" "battery" "controlCenterButton" "notificationButton"];
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

          enableFprint = true;
          greeterEnableFprint = true;
          acLockTimeout = 300;
          acMonitorTimeout = 600;
          acSuspendTimeout = 1800;
          acSuspendBehavior = 0;
          acProfileName = "2";
          batteryLockTimeout = 180;
          batteryMonitorTimeout = 300;
          batterySuspendTimeout = 900;
          batterySuspendBehavior = 2;
          batteryProfileName = "1";
          batteryChargeLimit = 100;
          lockBeforeSuspend = true;
          loginctlLockIntegration = true;
        };

        clipboardSettings = {
          maxHistory = 25;
          clearAtStartup = false;
        };

        plugins = {
          dankBatteryAlerts.enable = true;
          catWidget.enable = true;
          commandRunner.enable = true;
          calculator.enable = true;
          webSearch = {
            enable = true;
            settings.defaultEngine = "kagi";
          };
          emojiLauncher = {
            enable = true;
            settings = {
              noTrigger = false;
              trigger = ":";
            };
          };
          sessionPower.enable = true;
          screenRecorder = {
            enable = true;
            settings.outputDir = "${config.home.homeDirectory}/Videos/recordings";
          };
        };
      };

      home.packages = with pkgs; [
        qt6Packages.qtmultimedia
        swappy
        satty
      ];
    };
  };
}
