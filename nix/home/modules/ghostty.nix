{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    ghostty-config.enable =
      lib.mkEnableOption "enables ghostty terminal configuration";
  };

  config = lib.mkIf config.ghostty-config.enable {
    programs.ghostty = {
      enable = true;
      package = if pkgs.stdenv.isLinux then pkgs.ghostty else null;

      # Enable shell integration
      enableFishIntegration = true;

      settings = {
        gtk-single-instance = true;
        background-opacity = 0.98;
        theme = "Nordfox";
        # macOS: Make Option keys work as Alt (for nvim keymaps, etc.)
        macos-option-as-alt = true;

        # tmux-like navigation keybindings
        # keybind = [
        #   "ctrl+a>n=new_window"
        #   "ctrl+a>c=new_tab"
        #   "ctrl+a>1=goto_tab:1"
        #   "ctrl+a>2=goto_tab:2"
        #   "ctrl+a>3=goto_tab:3"
        #   "ctrl+a>4=goto_tab:4"
        #   "ctrl+a>5=goto_tab:5"
        #   "ctrl+a>6=goto_tab:6"
        #   "ctrl+a>7=goto_tab:7"
        #   "ctrl+a>8=goto_tab:8"
        #   "ctrl+a>9=goto_tab:9"
        #   "ctrl+a>s=new_split:down"
        #   "ctrl+a>v=new_split:right"
        #   "ctrl+a>h=goto_split:left"
        #   "ctrl+a>j=goto_split:bottom"
        #   "ctrl+a>k=goto_split:top"
        #   "ctrl+a>l=goto_split:right"
        #   "shift+enter=text:\\n"
        # ];
      };
    };
  };
}
