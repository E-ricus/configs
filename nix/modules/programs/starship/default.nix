# Starship prompt with jj-starship integration.
{inputs, ...}: {
  flake.modules.homeManager.starship = {pkgs, ...}: {
    home.packages = [
      pkgs.starship
      inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    xdg.configFile."starship.toml".text = builtins.readFile ./starship.toml;
  };
}
