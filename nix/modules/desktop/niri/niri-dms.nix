# Wrapped niri compositor for DMS (DankMaterialShell).
# Run standalone: nix run .#niri-dms
# TODO: Not actually able to run standalone as dms is a systemd service.
{
  self,
  inputs,
  den,
  ...
}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    dms = cmd: ["dms" "ipc" "call"] ++ (lib.splitString " " cmd);
  in {
    packages.niri-dms = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri-common];
      v2-settings = true;

      settings = {
        # Transparent background — DMS renders wallpaper via quickshell layer
        layout.background-color = "transparent";

        # ── DMS layer rules ─────────────────────────────────────────
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

        # ── DMS window rules ────────────────────────────────────────
        window-rules = [
          {
            matches = [{app-id = "^org\\.quickshell$";}];
            open-floating = true;
          }
        ];

        # ── DMS-specific keybinds ───────────────────────────────────
        binds = {
          # Launcher
          "Mod+D" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "spotlight toggle";
          };

          # Lock
          "Super+Alt+L" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "lock lock";
          };

          # Volume
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

          # Brightness
          "XF86MonBrightnessUp" = _: {
            props.allow-when-locked = true;
            content.spawn = dms "brightness increment 5 ";
          };
          "XF86MonBrightnessDown" = _: {
            props.allow-when-locked = true;
            content.spawn = dms "brightness decrement 5 ";
          };

          # Media
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

          # Screenshot via DMS
          "Print" = _: {
            props.allow-inhibiting = false;
            content.spawn = dms "niri screenshot";
          };

          # DMS-only extra binds
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

  # ── Aspect: niri + DMS on NixOS + home-manager ────────────────────
  den.aspects.niri-dms = {
    includes = [den.aspects.wayland den.aspects.dms];

    nixos = {pkgs, ...}: {
      programs.niri.enable = true;
      programs.niri.package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri-dms;
      services.displayManager.defaultSession = "niri";
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gnome];
      };
      environment.systemPackages = [pkgs.xwayland-satellite];
    };

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.hyprlock];
      # No swayidle — DMS handles idle/lock/suspend internally
      # No fuzzel — DMS has spotlight
    };
  };
}
