# Host: work-mac — macOS (nix-darwin), currently inactive.
#
# To activate:
#   1. Uncomment the nix-darwin input in flake.nix
#   2. Uncomment the darwinConfigurations block below (and add `inputs`,
#      `config` to this file's arguments)
#   3. Rebuild: darwin-rebuild switch --flake ~/configs/nix#work-mac
{...}: {
  # flake.darwinConfigurations.work-mac = inputs.nix-darwin.lib.darwinSystem {
  #   modules = [
  #     inputs.home-manager.darwinModules.home-manager
  #     ({pkgs, ...}: let
  #       user = "ericpuentes";
  #     in {
  #       environment.systemPackages = [pkgs.vim pkgs.home-manager];
  #
  #       nix.enable = false;
  #       nix.settings.experimental-features = "nix-command flakes";
  #       system.configurationRevision = null;
  #       system.stateVersion = 6;
  #       nixpkgs.hostPlatform = "aarch64-darwin";
  #       nixpkgs.config.allowUnfree = true;
  #
  #       programs.fish.enable = true;
  #
  #       system.keyboard = {
  #         enableKeyMapping = true;
  #         remapCapsLockToControl = true;
  #         swapLeftCtrlAndFn = true;
  #       };
  #
  #       homebrew = {
  #         enable = true;
  #         onActivation = {
  #           autoUpdate = true;
  #           cleanup = "zap";
  #           upgrade = true;
  #         };
  #         taps = [
  #           "nikitabobko/tap"
  #           "withgraphite/tap"
  #         ];
  #         brews = [
  #           "cargo-binstall"
  #           "reattach-to-user-namespace"
  #           "openssl@3"
  #           "withgraphite/tap/graphite"
  #         ];
  #         casks = [
  #           "alacritty"
  #           "nikitabobko/tap/aerospace"
  #           "font-jetbrains-mono-nerd-font"
  #           "font-symbols-only-nerd-font"
  #         ];
  #       };
  #
  #       networking.hostName = "work-mac";
  #       users.knownUsers = [user];
  #       system.primaryUser = user;
  #       users.users.${user} = {
  #         uid = 501;
  #         shell = pkgs.fish;
  #         home = "/Users/${user}";
  #       };
  #
  #       home-manager.users.${user} = {
  #         imports = with config.flake.modules.homeManager; [
  #           defaults
  #           darwin-tools
  #           aerospace
  #         ];
  #         programs.fish.enable = true;
  #         home = {
  #           username = user;
  #           homeDirectory = "/Users/${user}";
  #           sessionPath = [
  #             "/nix/var/nix/profiles/default/bin"
  #             "/etc/profiles/per-user/${user}/bin"
  #             "/run/current-system/sw/bin"
  #             "/opt/homebrew/bin"
  #             "/opt/homebrew/sbin"
  #           ];
  #         };
  #       };
  #     })
  #   ];
  # };
}
