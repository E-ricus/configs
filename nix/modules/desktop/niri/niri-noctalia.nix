# Wrapped niri compositor for Noctalia.
# Run standalone: nix run .#niri-noctalia
{
  self,
  inputs,
  den,
  ...
}: {
  # ── Standalone package (nix run .#niri-noctalia, scale 1.0) ───────
  perSystem = {pkgs, ...}: {
    packages.niri-noctalia = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri-common self.wrappersModules.niri-noctalia];
    };
  };

  # ── Aspect: niri + Noctalia on NixOS + home-manager ───────────────
  den.aspects.niri-noctalia = den.lib.parametric {
    includes = [
      den.aspects.wayland
      den.aspects.wayland-regreet
      den.aspects.noctalia
      # Parametric include: receives {host}, injects per-host scale
      ({host}: {
        nixos = {pkgs, ...}: let
          niriPkg = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            imports = [self.wrappersModules.niri-common self.wrappersModules.niri-noctalia];
            settings.outputs."eDP-1".scale = host.display.scale;
          };
        in {
          programs.niri.enable = true;
          programs.niri.package = niriPkg;
          services.displayManager.defaultSession = "niri";
          xdg.portal = {
            enable = true;
            extraPortals = [pkgs.xdg-desktop-portal-gnome];
          };
          environment.systemPackages = [pkgs.xwayland-satellite];
        };
      })
    ];

    homeManager = {pkgs, lib, config, ...}: let
      noctaliaShell = self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      lockScript =
        pkgs.writeShellScript "lock-screen"
        "${noctaliaShell}/bin/noctalia-shell ipc call lockScreen lock";
    in {
      home.packages = [pkgs.hyprlock pkgs.satty];

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
