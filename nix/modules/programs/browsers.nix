# Web browsers — Firefox + Brave.
{den, ...}: {
  den.aspects.browsers = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.brave];
      programs.firefox.enable = true;
    };
  };
}
