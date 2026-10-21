# Direnv — automatic environment switching for project directories.
{...}: {
  flake.modules.homeManager.direnv = {...}: {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
      config.whitelist.prefix = ["~/code/" "~/Projects"];
    };
  };
}
