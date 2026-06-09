# Yazi — terminal file manager.
{...}: {
  den.aspects.yazi = {
    homeManager = {...}: {
      programs.yazi = {
        enable = true;
        shellWrapperName = "y";
      };
    };
  };
}
