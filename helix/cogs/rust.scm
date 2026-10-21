;;; cogs/rust.scm — rust-analyzer with target switching.
;;;
;;; Mirrors the neovim (rustaceanvim) setup:
;;;   * rust-analyzer is launched directly from PATH.
;;;   * cargo.target / cargo.features are passed as rust-analyzer settings, and
;;;     switching target restarts the server.
;;;
;;; Two presets (same as nvim):
;;;   host                -> target "",                 no features
;;;   windows             -> x86_64-pc-windows-gnu,     no features
;;;
;;; NOTE: rust-analyzer must be on PATH (from project's devshell / rustup),
;;; exactly as with neovim, so launch `hx` from inside the project's
;;; direnv/devshell.

(require "helix/configuration.scm")
(require (prefix-in helix. "helix/commands.scm"))
(require "helix/misc.scm")

(require "notify/notify.scm")

(provide rust-target-host
         rust-target-windows)

;; Assemble the rust-analyzer settings (the `config` hash == RA initialization
;; options). Matches the nvim/emacs setup:
;;   checkOnSave off, buildScripts + procMacro on, clippy check (non-workspace),
;;   sql-string semantic highlighting off. cargo.target/features applied only
;;   when set.
(define (ra-config target features)
  (define cargo
    (let ([base (hash "buildScripts" (hash "enable" #t))])
      (let ([with-target
             (if (equal? target "")
                 base
                 (hash-insert base "target" target))])
        (if (null? features)
            with-target
            (hash-insert with-target "features" features)))))
  (hash "cargo" cargo
        "procMacro" (hash "enable" #t)
        "checkOnSave" #f
        "check" (hash "command" "clippy" "workspace" #f)
        "semanticHighlighting" (hash "strings" (hash "enable" #f))))

;; Set the rust-analyzer lsp config (command and RA settings). Config-only: does
;; NOT touch the current document/view, so it is SAFE to call at startup
;; (init.scm) before any buffer is open.
(define (set-rust-target! target features)
  (set-lsp-config! "rust-analyzer"
                   (hash "command" "rust-analyzer"
                         "config" (ra-config target features))))

;; Apply a target interactively: set the config, then restart the server so it
;; picks up the new target — equivalent to nvim's `RustAnalyzer restart`. MUST NOT be called at startup: `lsp-restart`
;; dereferences the current document (`doc!`) which panics when no view exists
;; (helix-view/src/tree.rs:301). Only call this when a buffer is open.
(define (apply-rust-target target features label)
  (set-rust-target! target features)
  (helix.lsp-restart)
  (set-status! (string-append "rust-analyzer target: " label)))

;; Startup entry point — configure the host target only (no restart, no status),
;; safe to call at top-level in init.scm. rust-analyzer will pick this config up
;; when it first launches on opening a rust file.
(provide rust-init!)
(define (rust-init!)
  (set-rust-target! "" '()))

;; Public presets ---------------------------------------------------------------


;;@doc
;; Switches rust target to host
(define (rust-target-host)
  (apply-rust-target "" '() "host")
  (notify "Switch rust-analyzer to host"))

;;@doc
;; Switches rust target to windows
(define (rust-target-windows)
  (apply-rust-target "x86_64-pc-windows-gnu" '() "windows-gnu")
  (notify "Switch rust-analyzer to windows"))
