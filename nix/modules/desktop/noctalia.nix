# Noctalia desktop shell — wrapped with baked-in config.
# Run standalone: nix run .#noctalia-shell
# Compositor-agnostic: composable with niri, hyprland, etc.
{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      # TODO: If using the $HOME variable the env variable set by the wrapper seems to have the literal value breaking this. Not having it set. doesn't allow runtime modifications. And I would prefer to not have my user hardcoded. but fine for now
      outOfStoreConfig = "/home/ericus/.config/noctalia";
      env.NOCTALIA_CACHE_DIR = "/tmp/noctalia-cache/";
      colors = {
        mPrimary = "#cba6f7"; # Mauve
        mOnPrimary = "#11111b"; # Crust
        mSecondary = "#fab387"; # Peach
        mOnSecondary = "#11111b"; # Crust
        mTertiary = "#94e2d5"; # Teal
        mOnTertiary = "#11111b"; # Crust
        mError = "#f38ba8"; # Red
        mOnError = "#11111b"; # Crust
        mSurface = "#1e1e2e"; # Base
        mSurfaceVariant = "#313244"; # Surface0
        mOnSurface = "#cdd6f4"; # Text
        mOnSurfaceVariant = "#a3b4eb"; # custom blue-lavender
        mOutline = "#4c4f69"; # Overlay2
        mShadow = "#11111b"; # Crust
        mHover = "#94e2d5"; # Teal
        mOnHover = "#11111b"; # Crust
      };
      settings = {
        settingsVersion = 37;
        bar = {
          position = "top";
          backgroundOpacity = 1;
          monitors = [];
          density = "default";
          showCapsule = false;
          capsuleOpacity = 1;
          floating = false;
          marginVertical = 0.25;
          marginHorizontal = 0.25;
          outerCorners = true;
          exclusive = true;
          widgets = {
            left = [
              {id = "ControlCenter";}
              {id = "Workspace";}
              {id = "ActiveWindow";}
              {id = "MediaMini";}
              {id = "plugin:catwalk";}
            ];
            center = [
              {
                id = "Clock";
                usePrimaryColor = false;
              }
            ];
            right = [
              {id = "plugin:privacy-indicator";}
              {id = "Tray";}
              {id = "plugin:network-manager-vpn";}
              {id = "plugin:screen-recorder";}
              {id = "SystemMonitor";}
              {id = "Battery";}
              {id = "Volume";}
              {id = "Network";}
              {id = "Bluetooth";}
              {id = "NotificationHistory";}
            ];
          };
        };
        general = {
          avatarImage = "";
          dimmerOpacity = 0.6;
          showScreenCorners = false;
          forceBlackScreenCorners = false;
          scaleRatio = 1;
          radiusRatio = 1;
          iRadiusRatio = 1;
          boxRadiusRatio = 1;
          screenRadiusRatio = 1;
          animationSpeed = 1;
          animationDisabled = false;
          compactLockScreen = false;
          autoStartAuth = true;
          allowPasswordWithFprintd = true;
          lockOnSuspend = true;
          showSessionButtonsOnLockScreen = true;
          showHibernateOnLockScreen = false;
          enableShadows = true;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          language = "";
          allowPanelsOnScreenWithoutBar = true;
        };
        ui = {
          fontDefault = "";
          fontFixed = "";
          fontDefaultScale = 1;
          fontFixedScale = 1;
          tooltipsEnabled = true;
          panelBackgroundOpacity = 1;
          panelsAttachedToBar = true;
          settingsPanelMode = "centered";
        };
        location = {
          name = "Berlin";
          weatherEnabled = true;
          weatherShowEffects = true;
          useFahrenheit = false;
          use12hourFormat = false;
          showWeekNumberInCalendar = false;
          showCalendarEvents = true;
          showCalendarWeather = true;
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
        };
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "timer-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };
        wallpaper = {
          enabled = true;
          overviewEnabled = false;
          directory = "";
          monitorDirectories = [];
          enableMultiMonitorDirectories = false;
          viewMode = "single";
          setWallpaperOnAllMonitors = true;
          fillMode = "crop";
          fillColor = "#000000";
          automationEnabled = false;
          randomIntervalSec = 300;
          transitionDuration = 1500;
          transitionType = "random";
          transitionEdgeSmoothness = 0.05;
          panelPosition = "follow_bar";
          hideWallpaperFilenames = false;
          useWallhaven = false;
          wallhavenQuery = "";
          wallhavenSorting = "relevance";
          wallhavenOrder = "desc";
          wallhavenCategories = "111";
          wallhavenPurity = "100";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenResolutionHeight = "";
        };
        appLauncher = {
          enableClipboardHistory = false;
          enableClipPreview = true;
          position = "center";
          pinnedExecs = [];
          useApp2Unit = false;
          sortByMostUsed = true;
          terminalCommand = "ghostty -e";
          customLaunchPrefixEnabled = false;
          customLaunchPrefix = "";
          viewMode = "list";
          showCategories = true;
        };
        controlCenter = {
          position = "close_to_bar_button";
          shortcuts = {
            left = [
              {id = "Network";}
              {id = "Bluetooth";}
              {id = "WallpaperSelector";}
              {id = "NoctaliaPerformance";}
            ];
            right = [
              {id = "Notifications";}
              {id = "PowerProfile";}
              {id = "KeepAwake";}
              {id = "NightLight";}
            ];
          };
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
        };
        systemMonitor = {
          cpuWarningThreshold = 80;
          cpuCriticalThreshold = 90;
          tempWarningThreshold = 80;
          tempCriticalThreshold = 90;
          memWarningThreshold = 80;
          memCriticalThreshold = 90;
          diskWarningThreshold = 80;
          diskCriticalThreshold = 90;
          cpuPollingInterval = 3000;
          tempPollingInterval = 3000;
          memPollingInterval = 3000;
          diskPollingInterval = 3000;
          networkPollingInterval = 3000;
          useCustomColors = false;
          warningColor = "";
          criticalColor = "";
        };
        dock = {
          enabled = true;
          displayMode = "auto_hide";
          backgroundOpacity = 1;
          floatingRatio = 1;
          size = 1;
          onlySameOutput = true;
          monitors = [];
          pinnedApps = [];
          colorizeIcons = false;
          pinnedStatic = false;
          inactiveIndicators = false;
          deadOpacity = 0.6;
        };
        network = {wifiEnabled = true;};
        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 10000;
          position = "center";
          showHeader = true;
          powerOptions = [
            {
              action = "lock";
              enabled = true;
            }
            {
              action = "suspend";
              enabled = true;
            }
            {
              action = "hibernate";
              enabled = true;
            }
            {
              action = "reboot";
              enabled = true;
            }
            {
              action = "logout";
              enabled = true;
            }
            {
              action = "shutdown";
              enabled = true;
            }
          ];
        };
        notifications = {
          enabled = true;
          monitors = [];
          location = "top_right";
          overlayLayer = true;
          backgroundOpacity = 1;
          respectExpireTimeout = false;
          lowUrgencyDuration = 3;
          normalUrgencyDuration = 5;
          criticalUrgencyDuration = 10;
          enableKeyboardLayoutToast = true;
          sounds = {
            enabled = false;
            volume = 0.5;
            separateSounds = false;
            criticalSoundFile = "";
            normalSoundFile = "";
            lowSoundFile = "";
            excludedApps = "discord,firefox,chrome,chromium,edge";
          };
        };
        osd = {
          enabled = true;
          location = "top_right";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = 1;
          enabledTypes = [0 1 2];
          monitors = [];
        };
        audio = {
          volumeStep = 5;
          volumeOverdrive = false;
          cavaFrameRate = 30;
          visualizerType = "linear";
          visualizerQuality = "high";
          mprisBlacklist = [];
          preferredPlayer = "";
          externalMixer = "pwvucontrol || pavucontrol";
        };
        brightness = {
          brightnessStep = 5;
          enforceMinimum = true;
          enableDdcSupport = false;
        };
        colorSchemes = {
          useWallpaperColors = false;
          predefinedScheme = "Catppuccin";
          darkMode = true;
          schedulingMode = "off";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          matugenSchemeType = "scheme-fruit-salad";
          generateTemplatesForPredefined = true;
        };
        templates = {
          gtk = true;
          qt = true;
          kcolorscheme = true;
          alacritty = false;
          kitty = false;
          ghostty = false;
          foot = false;
          wezterm = false;
          fuzzel = true;
          discord = false;
          pywalfox = false;
          vicinae = false;
          walker = false;
          code = false;
          spicetify = false;
          telegram = false;
          cava = false;
          emacs = false;
          niri = false;
          enableUserTemplates = false;
        };
        nightLight = {
          enabled = false;
          forced = false;
          autoSchedule = true;
          nightTemp = "4000";
          dayTemp = "6500";
          manualSunrise = "06:30";
          manualSunset = "18:30";
        };
        hooks = {
          enabled = false;
          wallpaperChange = "";
          darkModeChange = "";
        };
        idle = {
          enabled = true;
          lockTimeout = 300;
          screenOffTimeout = 600;
          suspendTimeout = 1800;
          fadeDuration = 5;
          screenOffCommand = "${pkgs.niri}/bin/niri msg action power-off-monitors";
          lockCommand = "";
          suspendCommand = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
          resumeScreenOffCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
          resumeLockCommand = "";
          resumeSuspendCommand = "";
          customCommands = "[]";
        };
      };
      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        version = 2;
      };
      preInstalledPlugins = {
        catwalk = {
          src = "${inputs.noctalia-plugins}/catwalk";
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          settings = {
            minimumThreshold = 25;
            hideBackground = true;
          };
        };
        polkit-agent = {
          src = "${inputs.noctalia-plugins}/polkit-agent";
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        screen-recorder = {
          src = "${inputs.noctalia-plugins}/screen-recorder";
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        privacy-indicator = {
          src = "${inputs.noctalia-plugins}/privacy-indicator";
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        network-manager-vpn = {
          src = "${inputs.noctalia-plugins}/network-manager-vpn";
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        clipper = {
          src = "${inputs.noctalia-plugins}/clipper";
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
    };
  };

  den.aspects.noctalia = {
    homeManager = {pkgs, ...}: {
      home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell];
    };
  };
}
