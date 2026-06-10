;;; init.el --- Main Emacs configuration -*- lexical-binding: t; -*-

;;; ---- Package Management ---------------------------------------------------

(require 'package)
;; Redirect installed packages out of the config dir (which is a git repo).
(setq package-user-dir
      (expand-file-name "emacs/elpa/"
                        (or (getenv "XDG_DATA_HOME") "~/.local/share")))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; use-package is built-in since Emacs 29.
(require 'use-package)
(setq use-package-always-ensure t)

;;; ---- No Littering ---------------------------------------------------------
;; Automatically redirects ALL package data files to XDG locations.
;; No need to manually set paths for savehist, recentf, save-place, etc.

;; Set directories BEFORE loading so they're in effect immediately.
(setq no-littering-etc-directory
      (expand-file-name "emacs/etc/"
                        (or (getenv "XDG_DATA_HOME") "~/.local/share")))
(setq no-littering-var-directory
      (expand-file-name "emacs/var/"
                        (or (getenv "XDG_CACHE_HOME") "~/.cache")))

(use-package no-littering
  :demand t
  :config
  (setq custom-file (no-littering-expand-etc-file-name "custom.el")))

;;; ---- Local Packages -------------------------------------------------------
;; Standalone .el files in emacs/local/ (not on MELPA).
;; Drop a file there, then (require 'name) below or in the Language Modes section.
(add-to-list 'load-path (expand-file-name "local" user-emacs-directory))

;;; ---- Sensible Defaults ----------------------------------------------------

;; Startup
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; Line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
;; Disable line numbers in some modes where they make no sense.
(dolist (mode '(term-mode-hook
               eshell-mode-hook
               treemacs-mode-hook
               org-agenda-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Show column number in modeline
(column-number-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; Clipboard — sync kill-ring with system clipboard
;; Makes evil yank/paste (y/p) work with system clipboard.
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; Encoding
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Scrolling
(setq scroll-margin 8)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)
(pixel-scroll-precision-mode 1)

;; Auto-revert buffers when files change on disk
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; Remember cursor position across sessions
(save-place-mode 1)

;; Recent files
(recentf-mode 1)
(setq recentf-max-items 50)

;; Auto-close brackets, quotes, etc.
(electric-pair-mode 1)

;; Show matching parens
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Don't litter the filesystem with backup/lock/autosave files
(setq make-backup-files nil)
(setq create-lockfiles nil)
(setq auto-save-default nil)

;; custom-set-variables go to a separate file (path managed by no-littering)
(when (and custom-file (file-exists-p custom-file))
  (load custom-file 'noerror))

;; Use y/n instead of yes/no
(setopt use-short-answers t)

;; Indentation
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;; Delete trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Typed text replaces the selection
(delete-selection-mode 1)

;; Don't wrap lines by default; toggle with M-x visual-line-mode
(setq-default truncate-lines t)

;; Unique buffer names: show path when names collide
(setq uniquify-buffer-name-style 'forward)

;; Better dired defaults
(setq dired-listing-switches "-alh --group-directories-first")
(setq dired-dwim-target t)
(setq dired-mouse-drag-files t)              ; drag files out of dired (Emacs 29+)
(require 'dired-x)                           ; extra commands (C-x C-j jump to dired, etc.)
(setq dired-omit-files                       ; hide dotfiles; toggle with C-x M-o
      (concat dired-omit-files "\\|^\\..+$"))
(add-hook 'dired-mode-hook 'dired-omit-mode)

;; Project persistence — remember known projects across sessions
;; no-littering handles the file path; we just need to ensure it saves.
(setq project-remember-projects-under t)

;; TRAMP — don't litter remote machines with autosave files
(setq tramp-auto-save-directory "/tmp")

;; Zoom: C-= to increase, C-- to decrease, C-0 to reset
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-0") 'text-scale-adjust) ; reset with 0

;; Quick access to config
(global-set-key (kbd "C-c e i") (lambda () (interactive) (find-file user-init-file)))
(global-set-key (kbd "C-c e r") (lambda () (interactive) (load-file user-init-file) (message "init.el reloaded")))

;; Buffer management
(global-set-key (kbd "C-c b k") 'kill-this-buffer)     ; kill current buffer
(global-set-key (kbd "C-c b K") 'kill-buffer-and-window) ; kill buffer + close window

;; Native compilation (Emacs 29+) — silence warnings
(setq native-comp-async-report-warnings-errors nil)

;;; ---- Font -----------------------------------------------------------------

(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font"
                    :height 130)  ; 130 = 13pt — adjust to taste (100 = 10pt, 150 = 15pt)

;;; ---- Theme ----------------------------------------------------------------

(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin :no-confirm))

;;; ---- Evil Mode (Vim Keybindings) ------------------------------------------

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)   ; required for evil-collection
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-Y-yank-to-eol t)  ; Y yanks to eol (like modern vim)
  (setq evil-undo-system 'undo-redo) ; native undo-redo (Emacs 28+)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-mc
  :after evil
  :config
  (global-evil-mc-mode 1))

;;; ---- Completion (Minibuffer) ----------------------------------------------
;; vertico  — vertical completion UI
;; orderless — flexible fuzzy matching
;; marginalia — rich annotations
;; consult  — enhanced search/navigation commands (like telescope/fzf)

(use-package vertico
  :init (vertico-mode)
  :custom
  (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :bind (("C-s"     . consult-line)        ; search current buffer
         ("C-x b"   . consult-buffer)       ; enhanced buffer switching
         ("C-x f"   . consult-find)         ; find file in project
         ("C-x /"   . consult-ripgrep)      ; project-wide search (needs ripgrep)
         ("C-x r b" . consult-bookmark)
         ("M-g g"   . consult-goto-line)
         ("M-g M-g" . consult-goto-line)))

;; Persist completion history across sessions
(use-package savehist
  :ensure nil ; built-in
  :init (savehist-mode))

;;; ---- Completion (In-buffer) -----------------------------------------------
;; corfu — lightweight popup completion at point (like nvim cmp)
;; cape  — extra completion-at-point backends

(use-package corfu
  :custom
  (corfu-auto t)             ; auto-popup
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)     ; show after 2 characters
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :init (global-corfu-mode))

(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

;;; ---- LSP (Eglot — built-in) ----------------------------------------------
;; Eglot is built into Emacs 29+. Enable it per language via hooks:
;;
;;   (add-hook 'python-mode-hook  'eglot-ensure)
;;   (add-hook 'rust-mode-hook    'eglot-ensure)
;;   (add-hook 'go-mode-hook      'eglot-ensure)
;;   (add-hook 'c-mode-hook       'eglot-ensure)
;;   (add-hook 'js-mode-hook      'eglot-ensure)
;;   (add-hook 'c3-ts-mode-hook   'eglot-ensure)
;;
;; For languages without built-in server detection, register the server:
;;   (add-to-list 'eglot-server-programs '(c3-ts-mode "c3lsp"))
;;
;; Just install the language server (e.g. pyright, rust-analyzer, gopls, c3lsp)
;; and uncomment the hook + server program for that language.
;; envrc will pick up the LSP binary from your project's nix devshell.

(use-package eglot
  :ensure nil ; built-in
  :custom
  (eglot-autoshutdown t)        ; shut down server when last buffer closes
  (eglot-events-buffer-size 0)  ; disable events log for performance
  :config
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider)))

;;; ---- Keybinding Discovery -------------------------------------------------

(use-package which-key
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.5))

;;; ---- Git (Magit) ----------------------------------------------------------

(use-package magit
  :bind (("C-c g s" . magit-status)
         ("C-c g l" . magit-log-current)
         ("C-c g b" . magit-blame)))
;; evil-collection already provides vim keybindings in magit buffers.

;;; ---- Snippets (YASnippet) -------------------------------------------------

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets  ; community snippet collection
  :after yasnippet)

;;; ---- Move Lines -----------------------------------------------------------

(use-package move-text
  :config
  ;; Alt-j / Alt-k to move lines — natural for vim users
  (define-key evil-normal-state-map (kbd "M-j") 'move-text-down)
  (define-key evil-normal-state-map (kbd "M-k") 'move-text-up)
  (define-key evil-visual-state-map (kbd "M-j") 'move-text-down)
  (define-key evil-visual-state-map (kbd "M-k") 'move-text-up))

;;; ---- Language Modes -------------------------------------------------------

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :custom
  (markdown-fontify-code-blocks-natively t)) ; syntax highlight fenced code blocks

(use-package yaml-mode
  :mode ("\\.ya?ml\\'"))

(use-package c3-ts-mode
  :ensure nil ; installed via package-vc, not MELPA
  :vc (:url "https://github.com/c3lang/c3-ts-mode")
  :mode "\\.c3\\'"
  :init
  (add-to-list 'treesit-language-source-alist
               '(c3 "https://github.com/c3lang/tree-sitter-c3"))
  ;; Auto-install the grammar if missing (needs a C compiler).
  (unless (treesit-language-available-p 'c3)
    (treesit-install-language-grammar 'c3)))

;; Local modes (from emacs/local/)
(require 'jai-mode)

;;; ---- Compile Mode ---------------------------------------------------------
;; Built-in. Runs a shell command, parses output for file:line errors,
;; lets you jump to each error with next-error / previous-error.
;; project-compile runs from the project root (detected via .git, etc.)

(global-set-key (kbd "C-c c c") 'project-compile)  ; compile from project root
(global-set-key (kbd "C-c c r") 'recompile)         ; re-run last compile
(global-set-key (kbd "M-g n")   'next-error)         ; jump to next error
(global-set-key (kbd "M-g p")   'previous-error)     ; jump to previous error

(setq compilation-scroll-output t)           ; auto-scroll compilation buffer
(setq compilation-ask-about-save nil)        ; save files before compiling without asking

;;; ---- Quality of Life ------------------------------------------------------

;; Highlight TODO/FIXME/NOTE in comments
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

;; Rainbow delimiters for nested parens
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Reset GC threshold after init (see early-init.el)
(setq gc-cons-threshold (* 16 1024 1024)) ; 16 MB

;;; init.el ends here
