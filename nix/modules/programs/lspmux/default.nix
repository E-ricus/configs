# lspmux — LSP multiplexer. Server runs as a systemd user service; editors
# connect via `lspmux client`. Instances are keyed by env + workspace root, so
# sharing is per-editor (different launch contexts don't share). RA_TARGET keys
# the instance per cargo target.
{
  den,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.lspmux = pkgs.callPackage ./_lspmux.nix {};
  };

  den.aspects.lspmux = {
    nixos = {pkgs, ...}: let
      lspmux = self.packages.${pkgs.stdenv.hostPlatform.system}.lspmux;
    in {
      environment.systemPackages = [lspmux];

      systemd.user.services.lspmux = {
        description = "LSP multiplexer";
        wantedBy = ["default.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lspmux}/bin/lspmux server";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };

    homeManager = {pkgs, ...}: let
      tomlFormat = pkgs.formats.toml {};
    in {
      xdg.configFile."lspmux/config.toml".source = tomlFormat.generate "lspmux-config" {
        # idle timeout (seconds) before a clientless instance is reaped
        instance_timeout = 30;
        # forward the full devshell env so rust-analyzer has the toolchain
        pass_environment = ["*"];
      };
    };
  };
}
