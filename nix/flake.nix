{
  description = "E-ric's nix configurations — Dendritic with Den + flake-parts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helix editor — mattwparas' fork with the Steel (Scheme) plugin system.
    # See PR helix-editor/helix#8675. Built with the `steel,git` features.
    helix-steel = {
      url = "github:mattwparas/helix/steel-event-system";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop environment
    # Noctalia v5 (alpha) shell. nixpkgs is intentionally NOT followed so the
    # Cachix binary cache (noctalia.cachix.org) can be used — see base/system.nix.
    noctalia.url = "github:noctalia-dev/noctalia";
    # System tools
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jetbrains-plugins = {
      url = "github:Janrupf/nix-jetbrains-plugin-repository";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wrapper modules — bake config into packages for portable derivations
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs pinned at the commit immediately BEFORE bun 1.3.13 -> 1.4.2
    # (4ba99f3, 2026-09-12). Used ONLY to build opencode, which the newer bun
    # miscompiles — see programs/llms.nix. Deliberately does not follow nixpkgs;
    # remove this input once that workaround goes away.
    nixpkgs-bun.url = "github:nixos/nixpkgs/d1248566e477e313530ea7f64e46ba3563bd895e";

    # Claude Desktop for Linux.
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Shell / prompt
    jj-starship = {
      url = "github:dmmulroy/jj-starship";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Darwin (inactive — uncomment to enable work-mac)
    # nix-darwin = {
    #   url = "github:nix-darwin/nix-darwin/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    (inputs.import-tree ./modules);
}
