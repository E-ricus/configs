# Emacs — bleeding-edge X11 (lucid) build via nix-community/emacs-overlay.
# X11 over pgtk on purpose: pgtk redisplay is throttled to the compositor on
# wlroots, making cursor motion sluggish; X11/XWayland is far smoother.
# Config lives at ~/configs/emacs/ and is symlinked to ~/.config/emacs/.
# Packages are primarily managed by use-package + MELPA from within Emacs.
# To additionally pin packages as Nix derivations, see the commented example below.
#
{inputs, ...}: let
  emacsOverlay = inputs.emacs-overlay.overlays.default;
in {
  den.aspects.emacs = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [emacsOverlay];

      services.emacs = {
        enable = true;
        package = pkgs.emacs-unstable;

        # To bundle Nix-managed packages alongside MELPA ones, replace the
        # line above with something like:
        # package = (pkgs.emacsPackagesFor pkgs.emacs-unstable).emacsWithPackages (epkgs: with epkgs; [
        #   vterm
        #   treesit-grammars.with-all-grammars
        # ]);
      };
    };

    # Overrides the package's generated emacsclient.desktop. The X11/lucid
    # daemon can only make frames on a real DISPLAY, so force one (falling
    # back to :1, which xwayland-satellite provides) instead of relying on
    # the launcher's environment.
    homeManager = {pkgs, ...}: let
      emacsclientLauncher = pkgs.writeShellScriptBin "emacsclient-frame" ''
        exec emacsclient --alternate-editor= --create-frame \
          --display="''${DISPLAY:-:1}" "$@"
      '';
    in {
      xdg.desktopEntries.emacsclient = {
        name = "Emacs (Client)";
        genericName = "Text Editor";
        comment = "Edit text";
        icon = "emacs";
        type = "Application";
        terminal = false;
        startupNotify = true;
        categories = ["Development"];
        exec = "${emacsclientLauncher}/bin/emacsclient-frame %F";
        mimeType = [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
        ];
      };
    };
  };
}
