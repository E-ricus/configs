{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Eric Puentes";
        email = "ericdpb@pm.me";
      };
      color.ui = true;
      core = {
        autocrlf = "input";
        editor = "vim";
        safecrlf = true;
      };
      alias = {
        ci = "commit";
        co = "checkout";
        s = "status";
        st = "status";
        br = "branch";
      };
      diff = {
        tool = "vimdiff";
        algorithm = "patience";
        compactionHeursitic = true;
      };
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      pull = {
        rebase = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
