{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./../common.nix
    ./../modules/hyperland.nix
  ];

  home = {
    username = "ericpuents";
    homeDirectory = "/Users/ericpuentes";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
