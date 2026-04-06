# Den framework wiring, schema definitions, and global defaults.
{
  inputs,
  den,
  lib,
  ...
}: {
  imports = [inputs.den.flakeModule];

  # Systems for perSystem outputs (devShells, packages, etc.)
  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

  # All users get home-manager integration
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  # Host schema: custom options available in host definitions
  den.schema.host = {lib, ...}: {
    options.scale = lib.mkOption {
      type = lib.types.either lib.types.int lib.types.float;
      default = 1.0;
      description = "Display scale factor for this host";
    };
  };

  # Enable mutual-provider: lets host aspects contribute homeManager config to users
  den.ctx.user.includes = [den._.mutual-provider];

  # Global defaults applied to all hosts/users
  den.default.nixos.system.stateVersion = "25.11";
  den.default.nixos.nixpkgs.config.allowUnfree = true;
  den.default.homeManager.home.stateVersion = "25.11";
  den.default.homeManager.programs.home-manager.enable = true;
}
