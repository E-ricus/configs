{den, ...}: {
  den.aspects.ericus = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "fish")

      den.aspects.tools
      den.aspects.git
      den.aspects.jujutsu
      den.aspects.direnv
      den.aspects.yazi
      den.aspects.nvim
      den.aspects.zed
      den.aspects.langs
      den.aspects.c3
      den.aspects.llms
      den.aspects.starship
      den.aspects.fish
      den.aspects.zsh
      den.aspects.nushell
      den.aspects.tmux
      den.aspects.ghostty
      den.aspects.alacritty

      den.aspects.niri-noctalia
      den.aspects.cosmic

      den.aspects.theming
      den.aspects.browsers
      den.aspects.aseprite
      den.aspects.linux-desktop
      den.aspects.containers
    ];

    user = {...}: {
      description = "Eric";
      extraGroups = ["networkmanager" "wheel" "video" "audio" "plugdev" "podman"];
    };

    homeManager = {config, ...}: {
      home.sessionPath = ["$HOME/.local/bin"];

      home.file.".local/bin".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/configs/bin";
    };
  };
}
