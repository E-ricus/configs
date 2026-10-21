{config, ...}: let
  inherit (config.flake.modules) nixos homeManager;
in {
  flake.modules.nixos.ericus = {pkgs, ...}: {
    # Desktop features with both a NixOS and a home-manager half
    # (each pulls its HM half in via home-manager.sharedModules).
    imports = with nixos; [
      niri-noctalia
      cosmic
      linux-desktop
      containers
      emacs
    ];

    programs.fish.enable = true;

    users.users.ericus = {
      isNormalUser = true;
      home = "/home/ericus";
      shell = pkgs.fish;
      description = "Eric";
      extraGroups = ["networkmanager" "wheel" "video" "audio" "plugdev" "podman"];
    };

    home-manager.users.ericus = {config, ...}: {
      imports = with homeManager; [
        tools
        git
        jujutsu
        direnv
        yazi
        nvim
        gram
        langs
        c3
        llms
        starship
        fish
        zsh
        nushell
        tmux
        ghostty
        alacritty
        theming
        browsers
        aseprite
      ];

      home.username = "ericus";
      home.homeDirectory = "/home/ericus";
      programs.fish.enable = true;

      home.sessionPath = ["$HOME/.local/bin"];

      home.file.".local/bin".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/configs/bin";
    };
  };
}
