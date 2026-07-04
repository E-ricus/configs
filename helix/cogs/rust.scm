;;; cogs/rust.scm — rust-analyzer via lspmux, with target switching.
;;;
;;; Mirrors the neovim (rustaceanvim) setup:
;;;   * rust-analyzer is launched through lspmux:
;;;       lspmux client --server-path rust-analyzer
;;;   * RA_TARGET="target|feat1|feat2" is set in the server ENVIRONMENT, which
;;;     keys the lspmux instance per target (so each target gets a warm server).
;;;   * cargo.target / cargo.features are passed as rust-analyzer settings.
;;;
;;; Three presets (same as nvim):
;;;   host                -> target "",                 no features
;;;   windows             -> x86_64-pc-windows-gnu,     no features
;;;   windows-codebase    -> x86_64-pc-windows-gnu,     allow-window use-codebase-lib
;;;
;;; NOTE: rust-analyzer must be on PATH (from project's devshell / rustup),
;;; exactly as with neovim. lspmux forwards the full env (pass_environment=["*"]),
;;; so launch `hx` from inside the project's direnv/devshell.

(require "helix/configuration.scm")
(require (prefix-in helix. "helix/commands.scm"))
(require "helix/misc.scm")

(require "notify/notify.scm")

(provide rust-target-host
         rust-target-windows
         rust-target-windows-codebase)

;; Build the RA_TARGET fingerprint that keys the lspmux instance:
;;   "target|feat1|feat2..."  ("" for host)
(define (ra-target-env target features)
  (define parts (cons target features))
  (hash "RA_TARGET" (string-join parts "|")))

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

;; Set the rust-analyzer lsp config (command via lspmux, env RA_TARGET, and the
;; RA settings). Config-only: does NOT touch the current document/view, so it is
;; SAFE to call at startup (init.scm) before any buffer is open.
(define (set-rust-target! target features)
  (set-lsp-config! "rust-analyzer"
                   (hash "command" "lspmux"
                         "args" (list "client" "--server-path" "rust-analyzer")
                         "environment" (ra-target-env target features)
                         "config" (ra-config target features))))

;; Apply a target interactively: set the config, then restart the server so
;; lspmux reconnects to the instance keyed by the new RA_TARGET — equivalent to
;; nvim's `RustAnalyzer restart`. MUST NOT be called at startup: `lsp-restart`
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


;;@doc
;; Switches rust target to windows + codebase
(define (rust-target-windows-codebase)
  (apply-rust-target "x86_64-pc-windows-gnu"
                     '("allow-window" "use-codebase-lib")
                     "windows-gnu + codebase")
  (notify "Switch rust-analyzer to windows"))
