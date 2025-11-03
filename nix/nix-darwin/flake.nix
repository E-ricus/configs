{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # My config
      programs.fish.enable = true;
      system.primaryUser = "ericpuentes";
      users.users.ericpuentes.uid = 501;
      users.users.ericpuentes.shell = pkgs.fish;
      users.users.ericpuentes.home = "/Users/ericpuentes";
      users.knownUsers = [ "ericpuentes" ];
    };
  in
  {
    # Build darwin flake using:
    # darwin-rebuild build --flake .#ericus
    darwinConfigurations."ericus" = nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs self; };
      modules = [ 
        configuration 
        inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ericpuentes = import ../home-manager/homes/mac.nix;
          }
      ];
    };
  };
}
