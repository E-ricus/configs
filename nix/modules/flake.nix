# Flake wiring and global defaults.
#
# Every file under modules/ is a flake-parts module (auto-imported by
# import-tree). Features publish plain NixOS / home-manager modules under
# `flake.modules.<class>.<name>`; hosts pick them with `imports`.
{
  inputs,
  lib,
  moduleLocation,
  config,
  ...
}: {
  # Systems for perSystem outputs
  config.systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

  config.perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };

  # Same as flake-parts' `flakeModules.modules`, but each module gets a `key`
  # so importing it from several places (e.g. `wayland` from both niri and
  # cosmic) only applies it once.
  options.flake.modules = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
    default = {};
    description = "NixOS / home-manager modules published by this flake, by class.";
    apply = lib.mapAttrs (class:
      lib.mapAttrs (name: module: {
        key = "${toString moduleLocation}#modules.${class}.${name}";
        _class = class;
        _file = "${toString moduleLocation}#modules.${class}.${name}";
        imports = [module];
      }));
  };

  # Global defaults, imported by every host.
  config.flake.modules.nixos.defaults = {lib, ...}: {
    imports = [inputs.home-manager.nixosModules.home-manager];

    options.my.display.scale = lib.mkOption {
      type = lib.types.either lib.types.int lib.types.float;
      default = 1.0;
      description = "Display scale factor for this host (read from HM via osConfig).";
    };

    config = {
      system.stateVersion = "25.11";
      nixpkgs.config.allowUnfree = true;
      home-manager.sharedModules = [config.flake.modules.homeManager.defaults];
    };
  };

  config.flake.modules.homeManager.defaults = {
    nixpkgs.config.allowUnfree = true;
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };
}
