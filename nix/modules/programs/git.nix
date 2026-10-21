# Git configuration.
{...}: let
  # Public signing key (not secret). Used for both the signingkey path file
  # and the allowed_signers entry that lets `git log --show-signature` verify.
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAk54gxDF94p6X28Xmxqv3iU8VouaVJs1deZqRZrLmXU signing";
in {
  flake.modules.homeManager.git = {config, ...}: {
    programs.lazygit.enable = true;

    # allowed_signers file so SSH signatures verify locally
    # (`git log --show-signature`). The public key itself is not secret.
    # NOTE: the .pub file already exists on this host and is referenced by
    # user.signingkey directly; home-manager does not manage it here to avoid
    # clobbering the existing file. (Revisit when adding new hosts.)
    home.file.".ssh/allowed_signers".text = "${config.programs.git.settings.user.email} namespaces=\"git\" ${signingKey}\n";

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Eric Puentes";
          email = "ericdpb@pm.me";
          signingkey = "~/.ssh/id_ed25519_signing.pub";
        };
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        commit.gpgsign = true;
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
          conflictstyle = "zdiff3";
        };
        pull.rebase = true;
        init.defaultBranch = "main";
      };
    };
  };
}
