# Wrapped niri compositor for DMS (DankMaterialShell).
# Run standalone: nix run .#niri-dms
# TODO: Not actually able to run standalone as dms is a systemd service.
{
  self,
  inputs,
  den,
  ...
}: {
  # ── Standalone package (nix run .#niri-dms, scale 1.0) ────────────
  perSystem = {pkgs, ...}: {
    packages.niri-dms = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri-common self.wrappersModules.niri-dms];
    };
  };

  # ── Aspect: niri + DMS on NixOS + home-manager ────────────────────
  den.aspects.niri-dms = den.lib.parametric {
    includes = [
      den.aspects.wayland
      den.aspects.dms
      # Parametric include: receives {host}, injects per-host scale
      ({host}: {
        nixos = {pkgs, ...}: let
          niriPkg = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            imports = [self.wrappersModules.niri-common self.wrappersModules.niri-dms];
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

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.hyprlock];
      # No swayidle — DMS handles idle/lock/suspend internally
    };
  };
}
