# Zed editor configuration.
{den, ...}: {
  den.aspects.zed = {
    homeManager = {...}: {
      programs.zed-editor = {
        enable = true;
        userSettings = {
          theme = "Gruvbox Dark Soft";
          vim_mode = true;
          relative_line_numbers = "enabled";
        };
        userKeymaps = [
          {
            context = "Editor && vim_operator == none && !VimWaiting && vim_mode != insert";
            bindings = {
              "space \`" = "workspace::ToggleLeftDock";
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
  };
}
