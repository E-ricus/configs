# User aspect for ericus — shared across hosts that use this user.
# The user definition is just aspect composition + system user config.
{den, ...}: {
  den.aspects.ericus = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "fish")

      # CLI tools and shells
      den.aspects.tools
      den.aspects.git
      den.aspects.jujutsu
      den.aspects.direnv
      den.aspects.yazi
      den.aspects.nvim
      den.aspects.zed
      den.aspects.langs
      den.aspects.llms
      den.aspects.starship
      den.aspects.fish
      den.aspects.zsh
      den.aspects.nushell
      den.aspects.tmux
      den.aspects.ghostty
      den.aspects.alacritty

      den.aspects.theming
      den.aspects.browsers
      den.aspects.linux-desktop
      den.aspects.containers
    ];

    user = {...}: {
      description = "Eric";
      extraGroups = ["networkmanager" "wheel" "video" "audio" "plugdev"];
    };
    home.sessionPath = ["$HOME/.local/bin"];
  };
}
