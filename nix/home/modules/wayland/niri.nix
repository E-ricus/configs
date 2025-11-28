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
  ];

  config = let
    brightnessScript = pkgs.writeShellScript "brightness-control" (builtins.readFile ../../config/wayland/brightness-control.sh);
    volumeScript = pkgs.writeShellScript "volume-control" (builtins.readFile ../../config/wayland/volume-control.sh);
  in
    lib.mkIf (config.wayland.enable && config.wayland.compositor == "niri") {
      # Enable walker and waybar by default when niri is enabled
      walker-config.enable = lib.mkDefault true;
      waybar-config.enable = lib.mkDefault true;
      swaybg-config.enable = lib.mkDefault true;

      xdg.configFile."niri/config.kdl".text = let
        configText = builtins.readFile ../../config/wayland/niri.kdl;
      in
        builtins.replaceStrings
        ["@BRIGHTNESS_SCRIPT@" "@VOLUME_SCRIPT@" "@WALLPAPER_PATH@"]
        ["${brightnessScript}" "${volumeScript}" "${config.swaybg-config.selectedWallpaperPath}"]
        configText;

      home.packages = with pkgs; [
        hyprlock
      ];
      programs.fuzzel.enable = true; # backup app launcher
      programs.satty.enable = true; # screenshot annotation

      xdg.configFile."hypr/hyprlock.conf".text = ''
        general {
          disable_loading_bar = true
          grace = 2
          hide_cursor = true
          no_fade_in = false
        }

        background {
          monitor =
          path = ${config.swaybg-config.selectedWallpaperPath}
          blur_passes = 3
          blur_size = 8
        }

        input-field {
          monitor =
          size = 200, 50
          outline_thickness = 3
          dots_size = 0.33
          dots_spacing = 0.15
          dots_center = false
          dots_rounding = -1
          outer_color = rgb(45475a)
          inner_color = rgb(1e1e2e)
          font_color = rgb(cdd6f4)
          fade_on_empty = true
          fade_timeout = 1000
          placeholder_text = <i>Input Password...</i>
          hide_input = false
          rounding = -1
          check_color = rgb(89b4fa)
          fail_color = rgb(f38ba8)
          fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
          fail_transition = 300
          capslock_color = -1
          numlock_color = -1
          bothlock_color = -1
          invert_numlock = false
          swap_font_color = false
          position = 0, -20
          halign = center
          valign = center
        }

        label {
          monitor =
          text = Hi there, $USER
          text_align = center
          color = rgb(cdd6f4)
          font_size = 32
          font_family = Noto Sans
          rotate = 0
          position = 0, 80
          halign = center
          valign = center
        }
      '';

      services.swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.hyprlock}/bin/hyprlock";
          }
          {
            event = "lock";
            command = "${pkgs.hyprlock}/bin/hyprlock";
          }
        ];
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.hyprlock}/bin/hyprlock";
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
