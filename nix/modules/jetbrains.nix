{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  jbLib = inputs.nix-jetbrains-plugins.lib;
  rustRoverPlugins = jbLib.pluginsForIde pkgs pkgs.jetbrains.rust-rover ["IdeaVIM"];
  dataGripPlugins = jbLib.pluginsForIde pkgs pkgs.jetbrains.datagrip ["IdeaVIM" "aws.toolkit" "aws.toolkit.core" "org.jetbrains.plugins.yaml"];
in {
  options = {
    jetbrains.enable =
      lib.mkEnableOption "enables jetbrains tools";
  };

  config = lib.mkIf config.jetbrains.enable {
    environment.systemPackages = [
      (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover (lib.attrValues rustRoverPlugins))
      (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.datagrip (lib.attrValues dataGripPlugins))
    ];
  };
}
