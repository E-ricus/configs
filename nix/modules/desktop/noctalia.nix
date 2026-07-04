# Noctalia v5 desktop shell — installed via the official Home Manager module.
# Docs: https://docs.noctalia.dev/v5/
# Config is written declaratively as programs.noctalia.settings (a Nix attrset);
# the module serializes it to ~/.config/noctalia/config.toml and validates it at
# build time with `noctalia config validate`.
{
  self,
  inputs,
  ...
}: {
  den.aspects.noctalia = {
    homeManager = {pkgs, ...}: let
      # Suspend-then-hibernate on battery, plain suspend on AC.
      powerAwareSuspend = pkgs.writeShellScript "power-aware-suspend" ''
        on_battery=$(${pkgs.upower}/bin/upower -d | ${pkgs.gnugrep}/bin/grep -oP 'on-battery:\s+\K\w+')

        if [ "$on_battery" = "yes" ]; then
          ${pkgs.systemd}/bin/systemctl suspend-then-hibernate
        else
          ${pkgs.systemd}/bin/systemctl suspend
        fi
      '';
    in {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia = {
        enable = true;
        # Run Noctalia as a systemd user service bound to the graphical session.
        systemd.enable = true;

        settings = {
          # ── Theme ──────────────────────────────────────────────────────
          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Catppuccin";
          };

          # ── Global shell behavior ──────────────────────────────────────
          shell = {
            # Built-in features that replaced v4 plugins.
            polkit_agent = true; # was the polkit-agent plugin
            clipboard_enabled = true; # was the clipper plugin
            # Run launched apps as transient systemd scopes so they survive a
            # shell restart (recommended when running as a systemd service).
            launch_apps_as_systemd_services = true;
            show_location = true;

            shadow = {
              direction = "down_right";
              alpha = 0.55;
            };

            panel = {
              launcher_placement = "centered";
              launcher_sort_by_usage = true;
            };
          };

          # ── Bar ────────────────────────────────────────────────────────
          bar = {
            order = ["main"];
            main = {
              position = "bottom";
              background_opacity = 1.0;
              reserve_space = true;
              margin_ends = 10;
              widget_spacing = 16;
              start = [
                "control-center"
                "workspaces"
                "active_window"
                "media"
                "audio_visualizer" # was the catwalk plugin
              ];
              center = ["clock"];
              end = [
                "tray"
                "spacer_end"
                "group:recorder_privacy"
                "sysmon"
                "battery"
                "volume"
                "network"
                "bluetooth"
                "notifications"
              ];
              # Capsule group: screen recorder + privacy indicator share one pill.
              capsule_group = [
                {
                  id = "recorder_privacy";
                  members = [
                    "noctalia/screen_recorder:recorder" # screen-recorder plugin
                    "privacy" # was the privacy-indicator plugin
                  ];
                  fill = "surface_variant";
                  opacity = 1.0;
                  padding = 6.0;
                }
              ];
            };
          };

          # Media widget: compact album-art style (matched v4 MediaMini intent).
          widget.media = {
            album_art_only = true;
            hide_when_no_media = true;
          };

          # Spacer used in the bar end lane.
          widget.spacer_end = {
            type = "spacer";
          };

          widget.clock = {
            format = "{:%d/%m %H:%M}";
          };

          # ── OSD ────────────────────────────────────────────────────────
          osd = {
            position = "bottom_right";
            background_opacity = 1.0;
          };

          # ── Notifications ──────────────────────────────────────────────
          notification = {
            enable_daemon = true;
            position = "bottom_right";
            background_opacity = 1.0;
          };

          # ── Audio ──────────────────────────────────────────────────────
          audio = {
            enable_overdrive = false;
            enable_sounds = false;
          };

          # ── System monitor ─────────────────────────────────────────────
          system.monitor = {
            enabled = true;
            cpu_poll_seconds = 3.0;
            memory_poll_seconds = 3.0;
            network_poll_seconds = 3.0;
            disk_poll_seconds = 10.0;
          };

          # ── Dock ───────────────────────────────────────────────────────
          dock = {
            enabled = true;
            auto_hide = true;
            icon_size = 26;
            reserve_space = false;
          };

          # ── Location & weather ─────────────────────────────────────────
          location = {
            address = "Berlin";
          };

          # ── Lock screen ────────────────────────────────────────────────
          lockscreen = {
            enabled = true;
            fingerprint = true; # was general.allowPasswordWithFprintd
          };

          # ── Wallpaper ──────────────────────────────────────────────────
          wallpaper = {
            enabled = true;
            fill_mode = "crop";
            directory = "/home/ericus/Pictures/wallpapers";
            default.path = "/home/ericus/Pictures/wallpapers/Cairn_Wallpaper_MorningRidge_4k.jpg";
          };

          # ── Idle ───────────────────────────────────────────────────────
          # v5 models idle as named behaviors. Lock → screen off → suspend,
          # with screen power handled by niri and a battery-aware suspend.
          idle = {
            pre_action_fade_seconds = 5.0;
            behavior = {
              lock = {
                enabled = true;
                timeout = 300;
                command = "noctalia:session lock";
              };
              screen-off = {
                enabled = true;
                timeout = 600;
                command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
                resume_command = "${pkgs.niri}/bin/niri msg action power-on-monitors";
              };
              suspend = {
                enabled = true;
                timeout = 1800;
                command = "${powerAwareSuspend}";
                # We lock via the lock behavior above; powerAwareSuspend handles
                # the suspend/hibernate decision itself.
                lock_before_suspend = true;
              };
            };
          };

          # ── Plugins ────────────────────────────────────────────────────
          # v5 fetches plugins from git sources. The official source ships
          # screen_recorder (used by the bar widget above). The v4 plugins
          # catwalk, clipper, polkit-agent, privacy-indicator, todo, and
          # network-manager-vpn have no v5 plugin equivalent — they are either
          # built into the shell or replaced by built-in widgets.
          plugins = {
            enabled = ["noctalia/screen_recorder"];
            source = [
              {
                name = "official";
                kind = "git";
                location = "https://github.com/noctalia-dev/official-plugins";
                auto_update = false;
              }
            ];
          };
        };
      };
    };
  };
}
