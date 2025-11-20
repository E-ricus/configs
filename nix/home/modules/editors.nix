{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    editors.enable = lib.mkEnableOption "enables editors";
    editors.zed.enable = lib.mkEnableOption "enables zed editor";
  };

  config = lib.mkIf config.editors.enable {
    # Enabled by default if editors is enabled, can be disabled
    editors.zed.enable = lib.mkDefault true;
    home.packages = with pkgs; [
      neovim # not ready to give my config to nix
      # needed for neovim
      luajitPackages.luarocks-nix
    ];

    programs.zed-editor = lib.mkIf config.editors.zed.enable {
      enable = true;
      userSettings = {
        theme = "Gruvbox Dark Soft";
        vim_mode = true;
        relative_line_numbers = true;
      };
      userKeymaps = [
        {
          context = "Editor && vim_operator == none && !VimWaiting && vim_mode != insert";
          bindings = {
            "space `" = "workspace::ToggleLeftDock";
            "space space" = "pane::AlternateFile";
            "shift k" = "editor::Hover";
            "space k" = "editor::Hover";
            "space t" = "workspace::ToggleBottomDock";
            "g r" = "editor::FindAllReferences";
            "g d" = "editor::GoToDefinition";
            "g i" = "editor::GoToImplementation";
            ctrl-space = "editor::ShowCompletions";
            "] d" = "editor::GoToDiagnostic";
            "[ d" = "editor::GoToPrevDiagnostic";
            "] g" = "editor::GoToHunk";
            "[ g" = "editor::GoToPrevHunk";
            "space f f" = "file_finder::Toggle";
            "space f b" = "tab_switcher::Toggle";
            "space /" = "workspace::NewSearch";
            "space l a" = "editor::ToggleCodeActions";
            "space l r" = "editor::Rename";
            "cmd /" = [
              "editor::ToggleComments"
              {
                advance_downwards = false;
              }
            ];
          };
        }
        {
          context = "Editor && vim_mode == insert";
          bindings = {
            ctrl-l = ["workspace::SendKeystrokes" "escape"];
          };
        }
      ];
    };
  };
}
