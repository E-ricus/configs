{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./../common.nix
  ];

  home = {
    username = "ericpuentes";
    homeDirectory = "/Users/ericpuentes";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
