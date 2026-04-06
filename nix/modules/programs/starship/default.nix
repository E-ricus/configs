# Starship prompt with jj-starship integration.
{
  den,
  inputs,
  ...
}: {
  den.aspects.starship = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        pkgs.starship
        inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      xdg.configFile."starship.toml".text = builtins.readFile ./starship.toml;
    };
  };
}
