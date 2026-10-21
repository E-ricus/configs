# Web browsers — Firefox + Brave.
{...}: {
  flake.modules.homeManager.browsers = {
    pkgs,
    config,
    ...
  }: {
    home.packages = [pkgs.brave];
    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };
}
