{...}: {
  flake.modules.homeManager.browsers = {
    pkgs,
    config,
    ...
  }: {
    home.packages = [pkgs.librewolf-bin pkgs.brave];
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };
}
