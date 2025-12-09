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

  config = let
    brightnessScript = pkgs.writeShellScript "brightness-control" (builtins.readFile ../../config/wayland/brightness-control.sh);
    volumeScript = pkgs.writeShellScript "volume-control" (builtins.readFile ../../config/wayland/volume-control.sh);

    # Use different lock commands based on whether noctalia is enabled
    lockScript =
      if config.noctalia-config.enable
      then
        pkgs.writeShellScript "lock-screen" ''
          noctalia-shell ipc call lockScreen toggle
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

      xdg.configFile."niri/config.kdl".text = let
        configText = builtins.readFile ../../config/wayland/niri.kdl;
        shellStartup =
          if config.noctalia-config.enable
          then ''spawn-sh-at-startup "noctalia-shell"''
          else ''spawn-sh-at-startup "swaybg -i ${config.swaybg-config.selectedWallpaperPath} -m fill"'';
        lockKeybind =
          if config.noctalia-config.enable
          then ''Super+Alt+L { spawn-sh "noctalia-shell ipc call lockScreen toggle"; }''
          else ''Super+Alt+L { spawn "hyprlock"; }'';
        volumeKeybinds =
          if config.noctalia-config.enable
          then ''
    XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume increase"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume decrease"; }
    XF86AudioMute        allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume muteOutput"; }''
          else ''
    XF86AudioRaiseVolume allow-when-locked=true { spawn "${volumeScript}" "raise"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "${volumeScript}" "lower"; }
    XF86AudioMute        allow-when-locked=true { spawn "${volumeScript}" "toggle-mute"; }'';
        launcherKeybind =
          if config.noctalia-config.enable
          then ''Mod+D { spawn-sh "noctalia-shell ipc call launcher toggle"; }''
          else ''Mod+D { spawn "walker"; }'';
      in
        builtins.replaceStrings
        ["@BRIGHTNESS_SCRIPT@" "@VOLUME_SCRIPT@" "@WALLPAPER_PATH@" "@SHELL_STARTUP@" "@LOCK_KEYBIND@" "@VOLUME_KEYBINDS@" "@LAUNCHER_KEYBIND@"]
        ["${brightnessScript}" "${volumeScript}" "${config.swaybg-config.selectedWallpaperPath}" shellStartup lockKeybind volumeKeybinds launcherKeybind]
        configText;

      home.packages = lib.optionals (!config.noctalia-config.enable) (with pkgs; [
        hyprlock
      ]);
      programs.fuzzel.enable = true; # backup app launcher
      programs.satty.enable = true; # screenshot annotation

      services.swayidle = {
        enable = true;
        systemdTarget = "niri-session.target";
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
    };
}
