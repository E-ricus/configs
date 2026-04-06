# Host aspect for work-mac — macOS (nix-darwin), currently inactive.
#
# To activate:
#   1. Uncomment the nix-darwin input in flake.nix
#   2. Uncomment den.hosts below
#   3. Rebuild: darwin-rebuild switch --flake ~/configs/nix#work-mac
#
# Previous flake.nix input:
#   nix-darwin = {
#     url = "github:nix-darwin/nix-darwin/master";
#     inputs.nixpkgs.follows = "nixpkgs";
#   };
#
{den, ...}: {
  # den.hosts.aarch64-darwin.work-mac.users.ericpuentes = {};

  den.aspects.work-mac = {
    # includes = [
    #   den.provides.hostname
    #   den.aspects.darwin-tools
    #   den.aspects.aerospace
    # ];

    # darwin = { pkgs, user, hostname, ... }: {
    #   environment.systemPackages = [pkgs.vim pkgs.home-manager];
    #
    #   nix.enable = false;
    #   nix.settings.experimental-features = "nix-command flakes";
    #   system.configurationRevision = null;
    #   system.stateVersion = 6;
    #   nixpkgs.hostPlatform = "aarch64-darwin";
    #   nixpkgs.config.allowUnfree = true;
    #
    #   programs.fish.enable = true;
    #
    #   system.keyboard = {
    #     enableKeyMapping = true;
    #     remapCapsLockToControl = true;
    #     swapLeftCtrlAndFn = true;
    #   };
    #
    #   homebrew = {
    #     enable = true;
    #     onActivation = {
    #       autoUpdate = true;
    #       cleanup = "zap";
    #       upgrade = true;
    #     };
    #     taps = [
    #       "nikitabobko/tap"
    #       "withgraphite/tap"
    #     ];
    #     brews = [
    #       "cargo-binstall"
    #       "reattach-to-user-namespace"
    #       "openssl@3"
    #       "withgraphite/tap/graphite"
    #     ];
    #     casks = [
    #       "alacritty"
    #       "nikitabobko/tap/aerospace"
    #       "font-jetbrains-mono-nerd-font"
    #       "font-symbols-only-nerd-font"
    #     ];
    #   };
    #
    #   networking.hostName = hostname;
    #   users.knownUsers = [user];
    #   system.primaryUser = user;
    #   users.users.${user} = {
    #     uid = 501;
    #     shell = pkgs.fish;
    #     home = "/Users/${user}";
    #   };
    # };

    # homeManager = { ... }: {
    #   home = {
    #     username = "ericpuentes";
    #     homeDirectory = "/Users/ericpuentes";
    #     sessionPath = [
    #       "/nix/var/nix/profiles/default/bin"
    #       "/etc/profiles/per-user/ericpuentes/bin"
    #       "/run/current-system/sw/bin"
    #       "/opt/homebrew/bin"
    #       "/opt/homebrew/sbin"
    #     ];
    #   };
    # };
  };
}
