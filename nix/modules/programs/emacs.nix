# Emacs — bleeding-edge pgtk build via nix-community/emacs-overlay.
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
        package = pkgs.emacs-unstable-pgtk;

        # To bundle Nix-managed packages alongside MELPA ones, replace the
        # line above with something like:
        # package = (pkgs.emacsPackagesFor pkgs.emacs-unstable-pgtk).emacsWithPackages (epkgs: with epkgs; [
        #   vterm
        #   treesit-grammars.with-all-grammars
        # ]);
      };
    };
  };
}
