# Wrapped niri compositor for Noctalia.
# Run standalone: nix run .#niri-noctalia
{
  self,
  inputs,
  den,
  ...
}: {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: let
    noctaliaExe = lib.getExe self'.packages.noctalia-shell;
    noctalia = cmd: [noctaliaExe "ipc" "call"] ++ (lib.splitString " " cmd);
    brightnessScript =
      pkgs.writeShellScript "brightness-control"
      (builtins.readFile ../wayland/brightness-control.sh);
  in {
    packages.niri-noctalia = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri-common];
      v2-settings = true;

      settings = {
        # Transparent background — Noctalia renders wallpaper via its own layer
        layout.background-color = "transparent";

        # Noctalia environment
        environment.NOCTALIA_PAM_SERVICE = "noctalia";

        # Spawn noctalia-shell at startup
        spawn-at-startup = [noctaliaExe];

        # ── Noctalia-specific keybinds ──────────────────────────────
        binds = {
          # Launcher
          "Mod+D" = _: {
            props.allow-inhibiting = false;
            content.spawn = noctalia "launcher toggle";
          };

          # Lock
          "Super+Alt+L" = _: {
            props.allow-inhibiting = false;
            content.spawn = noctalia "lockScreen lock";
          };

          # Volume via Noctalia IPC
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

          # Mic mute via wpctl (no noctalia IPC for this)
          "XF86AudioMicMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

          # Brightness via brightnessctl script
          "XF86MonBrightnessUp" = _: {
            props.allow-when-locked = true;
            content.spawn = ["${brightnessScript}" "raise"];
          };
          "XF86MonBrightnessDown" = _: {
            props.allow-when-locked = true;
            content.spawn = ["${brightnessScript}" "lower"];
          };

          # Media via playerctl
          "XF86AudioPlay".spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";
          "XF86AudioStop".spawn-sh = "${lib.getExe pkgs.playerctl} stop";
          "XF86AudioPrev".spawn-sh = "${lib.getExe pkgs.playerctl} previous";
          "XF86AudioNext".spawn-sh = "${lib.getExe pkgs.playerctl} next";
        };
      };
    };
  };

  # ── Aspect: niri + Noctalia on NixOS + home-manager ───────────────
  den.aspects.niri-noctalia = {
    includes = [den.aspects.wayland den.aspects.noctalia];

    nixos = {pkgs, ...}: {
      programs.niri.enable = true;
      programs.niri.package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri-noctalia;
      services.displayManager.defaultSession = "niri";
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gnome];
      };
      environment.systemPackages = [pkgs.xwayland-satellite];
    };

    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: let
      niriPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.niri-noctalia;
      noctaliaShell = self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      configDir = "${config.xdg.configHome}/niri";
      lockScript =
        pkgs.writeShellScript "lock-screen"
        "${noctaliaShell}/bin/noctalia-shell ipc call lockScreen lock";
    in {
      programs.fuzzel.enable = true;

      home.packages = [pkgs.hyprlock pkgs.satty];

      # User config includes the wrapped config + host overrides
      xdg.configFile."niri/config.kdl".text = ''
        include "${niriPkg}/niri-config.kdl"
        include "host.kdl"
      '';
      xdg.configFile."niri/host.kdl".text = lib.mkDefault "";
      # Override NIRI_CONFIG to use the user config (which includes the baked one)
      systemd.user.sessionVariables.NIRI_CONFIG = "${configDir}/config.kdl";

      # Idle management — Noctalia doesn't handle idle internally
      services.swayidle = {
        enable = true;
        systemdTarget = "graphical-session.target";
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
            command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
          }
        ];
      };
    };
  };
}
