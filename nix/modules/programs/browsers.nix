# Web browsers — Firefox + Brave.
{inputs, ...}: {
  flake.modules.homeManager.browsers = {
    pkgs,
    config,
    ...
  }: let
    # TODO: drop Brave (and the nixpkgs-brave flake input) — it was removed
    # from nixpkgs, so this pinned version gets no security fixes.
    pkgsBrave = import inputs.nixpkgs-brave {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  in {
    home.packages = [pkgsBrave.brave];
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };
}
