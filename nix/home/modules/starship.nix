{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    starship-config.enable =
      lib.mkEnableOption "enables starship prompt with jj-starship";
  };

  config = lib.mkIf config.starship-config.enable {
    home.packages = [
      pkgs.starship
      inputs.jj-starship.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.configFile."starship.toml".text = builtins.readFile ../config/starship/starship.toml;
  };
}
