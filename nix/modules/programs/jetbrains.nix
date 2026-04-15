# JetBrains IDEs — RustRover + DataGrip with plugins.
# Uses Janrupf/nix-jetbrains-plugin-repository which provides automatic
# compatibility checking and version selection per IDE.
#
{inputs, ...}: let
  jetbrainsOverlay = inputs.jetbrains-plugins.overlays.default;
in {
  den.aspects.jetbrains = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [
        jetbrainsOverlay
      ];

      environment.systemPackages = [
        (pkgs.jetbrains-plugins.lib.buildIdeWithPlugins pkgs.jetbrains.rust-rover (with pkgs.jetbrains-plugins; [
          IdeaVIM
        ]))
        (pkgs.jetbrains-plugins.lib.buildIdeWithPlugins pkgs.jetbrains.datagrip (with pkgs.jetbrains-plugins; [
          IdeaVIM
          aws.toolkit
          org.jetbrains.plugins.yaml
          com.github.catppuccin.jetbrains
        ]))
      ];
    };
  };
}
