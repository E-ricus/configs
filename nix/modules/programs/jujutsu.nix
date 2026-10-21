# Jujutsu VCS configuration.
{...}: {
  flake.modules.homeManager.jujutsu = {...}: {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = "ericdpb@pm.me";
          name = "Eric Puentes";
        };
      };
    };
  };
}
