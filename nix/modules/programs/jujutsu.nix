# Jujutsu VCS configuration.
{den, ...}: {
  den.aspects.jujutsu = {
    homeManager = {...}: {
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
  };
}
