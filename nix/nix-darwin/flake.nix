{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
  }: let
    configuration = {pkgs, ...}: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.vim
      ];

      nix.enable = false;
      # Necessary for using flakes on this system. (Should not be necessary if it's not enable I think)
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;

      # My config
      programs.fish.enable = true;
      system.primaryUser = "ericpuentes";
      users.users.ericpuentes.uid = 501;
      users.users.ericpuentes.shell = pkgs.fish;
      users.users.ericpuentes.home = "/Users/ericpuentes";
      users.knownUsers = ["ericpuentes"];
    };
  in {
    # Build darwin flake using:
    # darwin-rebuild build --flake .#ericus
    darwinConfigurations."ericus" = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit inputs self;};
      modules = [
        configuration
      ];
    };
  };
}
