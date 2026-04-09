# JetBrains IDEs — RustRover + DataGrip with plugins.
# Uses Janrupf/nix-jetbrains-plugin-repository which provides automatic
# compatibility checking and version selection per IDE.
#
# PINNED: DataGrip is pinned to 2025.3.5 because aws.toolkit and
# aws.toolkit.core are not yet compatible with DataGrip 2026.x.
# The plugin compatibility checker uses the IDE build number (253.x for 2025.3).
# To check if the pin can be removed:
#   1. Remove the datagrip overlay below
#   2. Run: nix eval .#nixosConfigurations.thinkpad-work.config.system.build.toplevel.drvPath
#   3. If it evaluates without "no compatible plugin" errors, remove the pin
{inputs, ...}: let
  jetbrainsOverlay = inputs.jetbrains-plugins.overlays.default;

  # Pin DataGrip to 2025.3.5 (build 253.25560.36) until aws.toolkit supports 2026.x builds.
  datgripPinOverlay = _final: prev: {
    jetbrains =
      prev.jetbrains
      // {
        datagrip = prev.jetbrains.datagrip.overrideAttrs (old: rec {
          pname = "datagrip";
          version = "2025.3.5";
          src = prev.fetchurl {
            url = "https://download.jetbrains.com/datagrip/datagrip-${version}.tar.gz";
            hash = "sha256-s9Zw7SUhmAzjhTf52nEerXNaP0l7kO/6J35xFtKf6TQ=";
          };
          passthru =
            (old.passthru or {})
            // {
              buildNumber = "253.25560.36";
            };
        });
      };
  };
in {
  den.aspects.jetbrains = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [
        datgripPinOverlay
        jetbrainsOverlay
      ];

      environment.systemPackages = [
        (pkgs.jetbrains-plugins.lib.buildIdeWithPlugins pkgs.jetbrains.rust-rover (with pkgs.jetbrains-plugins; [
          IdeaVIM
        ]))
        (pkgs.jetbrains-plugins.lib.buildIdeWithPlugins pkgs.jetbrains.datagrip (with pkgs.jetbrains-plugins; [
          IdeaVIM
          aws.toolkit
          aws.toolkit.core
          # YAML plugin: pinned version since auto-resolve fails for pinned DataGrip build.
          # It's a dependency of aws.toolkit. Pick latest 253.x stable version.
          org.jetbrains.plugins.yaml.stable."253.29346.50"
          com.github.catppuccin.jetbrains
        ]))
      ];
    };
  };
}
