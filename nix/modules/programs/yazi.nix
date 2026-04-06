# Yazi — terminal file manager.
{den, ...}: {
  den.aspects.yazi = {
    homeManager = {...}: {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
      };
    };
  };
}
