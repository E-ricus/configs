# Direnv — automatic environment switching for project directories.
{den, ...}: {
  den.aspects.direnv = {
    homeManager = {...}: {
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        enableFishIntegration = true;
        nix-direnv.enable = true;
        config.whitelist.prefix = ["~/code/" "~/Projects"];
      };
    };
  };
}
