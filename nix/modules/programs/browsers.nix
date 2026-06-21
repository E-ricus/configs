# Web browsers — Firefox + Brave.
{...}: {
  den.aspects.browsers = {
    homeManager = {
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
  };
}
