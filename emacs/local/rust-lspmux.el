;;; rust-lspmux.el --- rust-analyzer via the lspmux multiplexer -*- lexical-binding: t; -*-

;;; Commentary:
;; Runs rust-analyzer behind lspmux. RA_TARGET keys the lspmux instance per
;; cargo target, so `C-c r t' switches target (host default on first connect).
;; Edit targets in `my/rust-targets': (NAME . (TARGET FEATURES)), TARGET "" = host.

;;; Code:

(require 'cl-lib)

(defvar my/rust-target ""
  "Current cargo target for rust-analyzer (\"\" = host default).")

(defvar my/rust-features nil
  "List of cargo features currently enabled for rust-analyzer.")

(defvar my/rust-targets
  '(("host"                   . (""                       nil))
    ("windows-gnu"            . ("x86_64-pc-windows-gnu"   nil))
    ("windows-gnu + codebase" . ("x86_64-pc-windows-gnu"  ("allow-window" "use-codebase-lib"))))
  "Alist of NAME -> (TARGET FEATURES) presets for `my/rust-set-target'.")

(defun my/rust-fingerprint ()
  "RA_TARGET value for the current target+features (\"target|feat|feat\")."
  (mapconcat #'identity (cons my/rust-target my/rust-features) "|"))

(defun my/rust-settings ()
  "rust-analyzer settings for the current target/features (unwrapped).

This is the inner settings object rust-analyzer expects under
`initializationOptions' (no `:rust-analyzer' wrapper). cargo.target and
cargo.features are applied only when set. checkOnSave off; run a check
manually for diagnostics."
  `( :checkOnSave :json-false
     :cargo ( :buildScripts (:enable t)
              ,@(unless (string-empty-p my/rust-target)
                  (list :target my/rust-target))
              ,@(when my/rust-features
                  (list :features (vconcat my/rust-features))))
     :procMacro (:enable t)))

(defun my/rust-init-options (&rest _)
  "rust-analyzer `initializationOptions'.

Passed as a *function* in the eglot server contact so eglot re-evaluates
it on every connect — including `eglot-reconnect' (via saved-initargs) —
picking up the current target. This is the channel that actually reaches
rust-analyzer at `initialize' time (mirrors helix/neovim); the
`eglot-workspace-configuration' hook alone runs too late, after the
initial handshake, so it would send an empty config on a fresh connect."
  (my/rust-settings))

(defun my/rust-eglot-server (&optional _interactive _project)
  "rust-analyzer-via-lspmux server command; sets RA_TARGET for the instance key.

Ends with `:initializationOptions' so the target/features ride the
`initialize' request rather than a (mistimed) post-handshake
`didChangeConfiguration'."
  (setenv "RA_TARGET" (my/rust-fingerprint))
  (list "lspmux" "client" "--server-path" "rust-analyzer"
        :initializationOptions #'my/rust-init-options))

(defun my/rust-workspace-config (&rest _)
  "rust-analyzer settings for `eglot-workspace-configuration' (wrapped).

Belt-and-suspenders: keeps runtime `workspace/didChangeConfiguration' in
sync. `initializationOptions' (`my/rust-init-options') is the primary
channel at connect time."
  (list :rust-analyzer (my/rust-settings)))

(defun my/rust-eglot-config-hook ()
  "Feed `my/rust-workspace-config' to rust-analyzer buffers."
  (when (derived-mode-p 'rust-mode 'rust-ts-mode)
    (setq-local eglot-workspace-configuration #'my/rust-workspace-config)))

(defun my/rust-set-target (name)
  "Switch rust-analyzer to preset NAME and reconnect to its warm instance.

Updates RA_TARGET, then `eglot-reconnect's the running server. Because
`:initializationOptions' is a function (`my/rust-init-options'), eglot
re-evaluates it on reconnect and sends the new target/features in the
fresh `initialize' request. The reconnect re-manages every buffer of the
server (i.e. the whole project) automatically."
  (interactive
   (list (completing-read "Rust target: " (mapcar #'car my/rust-targets) nil t)))
  (let ((preset (cdr (assoc name my/rust-targets))))
    (unless preset (user-error "Unknown target: %s" name))
    (setq my/rust-target (nth 0 preset)
          my/rust-features (nth 1 preset))
    (setenv "RA_TARGET" (my/rust-fingerprint))
    (when (and (fboundp 'eglot-current-server) (eglot-current-server))
      (eglot-reconnect (eglot-current-server)))
    (message "Rust target: %s%s"
             (if (string-empty-p my/rust-target) "host" my/rust-target)
             (if my/rust-features
                 (format " [%s]" (string-join my/rust-features ", ")) ""))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((rust-mode rust-ts-mode) . my/rust-eglot-server)))

(add-hook 'eglot-managed-mode-hook #'my/rust-eglot-config-hook)

(with-eval-after-load 'rust-mode
  (define-key rust-mode-map (kbd "C-c r t") #'my/rust-set-target))

(provide 'rust-lspmux)
;;; rust-lspmux.el ends here
