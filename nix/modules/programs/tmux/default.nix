# Tmux — wrapped with plugins and config baked in.
# Run standalone: nix run .#tmux
{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.tmux = inputs.wrapper-modules.wrappers.tmux.wrap {
      inherit pkgs;
      plugins = [pkgs.tmuxPlugins.yank];
      configAfter = builtins.readFile ./tmux.conf;
    };
  };

  den.aspects.tmux = {
    homeManager = {pkgs, ...}: {
      home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.tmux];
    };
  };
}
