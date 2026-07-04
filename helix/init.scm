;;; init.scm — Steel plugin config for the helix steel fork.
;;;
;;; Docs: https://github.com/mattwparas/helix-config
;;; Install extra packages with:
;;;   forge install

(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))
(require "helix/configuration.scm")
(require "cogs/keymaps.scm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;; Options ;;;;;;;;;;;;;;;;;;;;;;;;;;

(file-picker (fp-hidden #f))
(cursorline #t)
(soft-wrap (sw-enable #t))

;;;;;;;;;;;;;;;;;;;;;;;;;; Keybindings ;;;;;;;;;;;;;;;;;;;;;;;
(keymap (global)
        (normal (C-x (o ":eval-sexpr"))))

;;;;;;;;;;;;;;;;;;;;;;; LSP + languages ;;;;;;;;;;;;;;;;;;;;;;;

;; Wire up the steel language server (shipped by the nixpkgs `steel` package,
;; on PATH as `steel-language-server`).
(define-lsp "steel-language-server"
  (command "steel-language-server")
  (args '()))

;; Teach helix about scheme files: format with the steel language server.
(define-language "scheme"
(auto-format #t)
  (language-servers '("steel-language-server")))

;; rust-analyzer via lspmux, with host/windows target switching.
(require "cogs/rust.scm")

;; Configure rust-analyzer for the host target by default on startup.
;; Config-only (no lsp-restart) so it's safe before any buffer is open.
(rust-init!)

(keymap (global)
  (normal
    (space
      (r
        (t
          (h ":rust-target-host")
          (w ":rust-target-windows")
          (c ":rust-target-windows-codebase"))))))

;;;;;;;;;;;;;;;;;;;;; Plugins ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notify forge pkg install --git https://github.com/chuwy/notify.hx.git
(require "notify/notify.scm")
;; Oil forge pkg install --git https://github.com/Ra77a3l3-jar/oil.hx.git
(require "oil/oil.scm")
(require "oil/oil-notify.scm") 

(keymap (global)
  (normal
    (space
      (o
        (o ":oil")
        (e ":oil-enter")
        (b ":oil-back")
        (g ":oil-root")
        (s ":oil-save")
        (r ":oil-refresh")
        (q ":oil-close")
        (h ":oil-toggle-hidden")
        (i ":oil-toggle-git-ignored")
        (m
          (y ":oil-yank")
          (x ":oil-cut")
          (p ":oil-paste")
          (c ":oil-clipboard-clear"))))))
