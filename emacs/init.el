;;; init.el --- Main Emacs configuration -*- lexical-binding: t; -*-

;;; ---- Package Management ---------------------------------------------------

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; use-package is built-in since Emacs 29.
(require 'use-package)
(setq use-package-always-ensure t)

;;; ---- Direnv (per-buffer nix shell environments) --------------------------
;; Loads .envrc / flake.nix devshell per-buffer

(use-package envrc
  :demand t
  :init (envrc-global-mode))

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
(setq select-enable-clipboard t)
;; Ctrl+Shift+V/C to paste/copy globally (minibuffer, etc.)
(global-set-key (kbd "C-S-v") 'clipboard-yank)
(global-set-key (kbd "C-S-c") 'clipboard-kill-ring-save)

;; Encoding
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Scrolling
(pixel-scroll-precision-mode 1) ; enable pixel-precise scrolling
(setq pixel-scroll-precision-interpolate t)

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

;; Put custom-set-variables in a separate file so they don't pollute init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
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
(setq dired-omit-files
      (concat dired-omit-files "\\|\\`\\.direnv\\'"))
(add-hook 'dired-mode-hook 'dired-omit-mode)

;; Project persistence — remember known projects across sessions
(setq project-remember-projects-under t)

;; Recognize projects by flake.nix or .envrc, not just .git
(defun my/project-try-flake (dir)
  "Detect project root by flake.nix or .envrc."
  (when-let* ((root (or (locate-dominating-file dir "flake.nix")
                        (locate-dominating-file dir ".envrc"))))
    (cons 'transient root)))
(with-eval-after-load 'project
  (add-to-list 'project-find-functions #'my/project-try-flake)
  ;; Auto-discover projects under ~/code (2 levels: code/{category}/{project})
  (when (file-directory-p "~/code")
    (dolist (dir (directory-files "~/code" t "\\`[^.]"))
      (when (file-directory-p dir)
        (project-remember-projects-under dir nil))))
  (setq project-switch-commands
        '((my/find-file-fuzzy  "Find file"    ?f)
          (consult-ripgrep     "Ripgrep"      ?g)
          (project-dired       "Dired"        ?d)
          (magit-status        "Magit"        ?m)
          (ghostel-project     "Terminal"     ?t)
          (project-eshell      "Eshell"       ?e)))
  (define-key project-prefix-map "f" #'my/find-file-fuzzy)
  ;; Bind C-x p d to project-dired (lowercase)
  (define-key project-prefix-map "d" #'project-dired))

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
                    :height 120)  ; 100 = 10pt

;;; ---- Themes ---------------------------------------------------------------

;; (use-package catppuccin-theme
;;   :config
;;   (setq catppuccin-flavor 'mocha)
;;   (load-theme 'catppuccin :no-confirm))

;; (use-package zenburn-theme
;;   :config
;;   (load-theme 'zenburn t))

(use-package gruber-darker-theme
  :config
  (load-theme 'gruber-darker t))

;;; ---- Undo ---------------------------------------------------------------
(use-package undo-fu)

;;; ---- Ghostell terminal ---------------------------------------------------
(use-package ghostel
  :bind (("C-c t" . ghostel)))

(use-package ghostel-eshell
  :ensure nil ;; bundled in ghostel
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

;;; ---- Evil Mode (Vim Keybindings) ------------------------------------------

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)    ; required for evil-collection
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-C-i-jump t)
  (setq evil-want-Y-yank-to-eol t)   ; Y yanks to eol (like modern vim)
  (setq evil-undo-system 'undo-fu)   ; Simpler predicateble
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  :config
  (evil-mode 1)

  ;; Visual paste: don't put replaced text into kill-ring/clipboard.
  (setq evil-kill-on-visual-paste nil)

  ;; Maps
  (define-key evil-normal-state-map (kbd "gr") 'xref-find-references)
  (define-key evil-normal-state-map (kbd "]d") 'next-error)
  (define-key evil-normal-state-map (kbd "[d") 'previous-error)
  (define-key evil-normal-state-map (kbd "SPC SPC") 'evil-switch-to-windows-last-buffer))

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

;;; ---- (multiple cursors) ----------------------------------------------
(use-package multiple-cursors
  :bind (("C-c m l"  .  mc/edit-lines)
         ("C->"      .  mc/mark-next-like-this)
         ("C-<"      .  mc/mark-previous-like-this)
         ("C-c C-<"  .  mc/mark-all-dwim)
         :map mc/keymap
         ("<return>" . newline)))

;;; ---- Completion (Minibuffer) ----------------------------------------------
;; vertico  — vertical completion UI
;; orderless — flexible fuzzy matching
;; marginalia — rich annotations
;; consult  — enhanced search/navigation commands

(use-package vertico
  :init (vertico-mode)
  :custom
  (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  ;; Flex = fzf/telescope-style fuzzy: chars match in order with gaps allowed.
  ;; A query like `conf/n/mod` is ONE component; the literal - and /
  ;; become anchors that must appear in order, so it's fuzzy *and* precise.
  (orderless-matching-styles '(orderless-flex))
  ;; Dispatchers — per-component escape hatches from flex:
  ;;   =foo  literal substring   !foo  exclude   ,    split into components
  (orderless-style-dispatchers
   '(my/orderless-literal-dispatcher
     my/orderless-not-dispatcher
     my/orderless-split-dispatcher))
  ;; Files keep partial-completion so path/ tab-completion still works,
  ;; with flex as the fallback for fuzzy fragments.
  (completion-category-overrides
   '((file (styles partial-completion orderless))))
  :config
  (defun my/orderless-literal-dispatcher (pattern _index _total)
    "Match PATTERN literally when it ends in =."
    (when (string-suffix-p "=" pattern)
      `(orderless-literal . ,(substring pattern 0 -1))))
  (defun my/orderless-not-dispatcher (pattern _index _total)
    "Exclude candidates matching PATTERN when it ends in !."
    (when (string-suffix-p "!" pattern)
      `(orderless-without-literal . ,(substring pattern 0 -1))))
  (defun my/orderless-split-dispatcher (pattern _index _total)
    "Treat , as a component separator (match the rest as a new flex term)."
    (when (string-suffix-p "," pattern)
      `(orderless-flex . ,(substring pattern 0 -1)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :bind (("C-x b"    . consult-buffer)                ; enhanced buffer switching
         ("C-x f"    . my/find-file-fuzzy)            ; find file in project (fuzzy, preview)
         ("C-x g"    . my/consult-ripgrep-word)       ; searchs for current word (needs ripgrep)
         ("C-x /"    . consult-ripgrep)               ; project-wide search (needs ripgrep)
         ("C-x r b"  . consult-bookmark)
         ("M-g g"    . consult-goto-line)
         ("M-g M-g"  . consult-goto-line))
  :config
  ;; Don't include project files in consult-buffer — it calls project-files
  ;; which runs `find` and chokes on permission-denied dirs.
  (setq consult-buffer-sources
        (delq 'consult--source-project-buffer
              (delq 'consult--source-project-recent-file
                    consult-buffer-sources)))

  (defun my/consult-ripgrep-word ()
    "Grep for the word at point in the current project using ripgrep."
    (interactive)
    (consult-ripgrep nil (thing-at-point 'word t)))

  ;; Fuzzy file finder. fd enumerates the whole tree into a static list
  ;; (fast: ~100k files in 50ms), then orderless-flex matches full relative
  ;; paths in-memory, so queries like `int/medatixx` match with gaps.
  ;; A static collection (not consult's async pipeline) is required so the
  ;; input reaches orderless instead of being consumed as a command/# split.
  (defun my/find-file-fuzzy ()
    "Find a file under the current project (or `default-directory') fuzzily."
    (interactive)
    (let* ((root (if-let* ((p (project-current))) (project-root p) default-directory))
           (default-directory root)
           (files (process-lines "fd" "--type" "f" "--strip-cwd-prefix"
                                 "--hidden" "--follow" "--exclude" ".git")))
      (find-file
       (consult--read
        files
        :prompt (format "File (%s): " (abbreviate-file-name root))
        :category 'file
        :state (consult--file-preview)
        :require-match t
        :sort nil)))))

;; Persist completion history across sessions
(use-package savehist
  :ensure nil ; built-in
  :init (savehist-mode))

;; embark — act on the candidate at point (like telescope actions / fzf binds).
;;   C-.  embark-act    :
;;                        (open in split, copy path, insert, run command, ...)
;;   C-;  embark-dwim   :
;;   C-h  (after C-.)   : browse all available actions with which-key
;; embark-consult bridges consult commands (consult-fd / consult-ripgrep) so
;; their candidates carry the right actions, and exports results to a buffer.
(use-package embark
  :bind (("C-."   . embark-act)         ;; menu of actions for the current candidate
         ("C-;"   . embark-dwim)        ;; run the most likely default action
         ("C-h B" . embark-bindings))   ; list all embark keybindings
  :init
  ;; Use embark to show the keymap prompt when you pause after a prefix key.
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

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
;; Eglot is built into Emacs 29+. Enable it per language via hooks anywhere:
;;
;;   (add-hook 'go-mode-hook      'eglot-ensure)
;;   (add-hook 'c3-ts-mode-hook   'eglot-ensure)
;;
;; For languages without built-in server detection, register the server:
;;   (add-to-list 'eglot-server-programs '(c3-ts-mode "c3-lsp"))

(use-package eglot
  :ensure nil ; built-in
  :custom
  (eglot-autoshutdown t)        ; shut down server when last buffer closes
  (eglot-events-buffer-size 0)  ; disable events log for performance
  ;; Don't block the UI on the connect/initialize handshake.
  (eglot-sync-connect nil)
  ;; Don't ask for semantic-tokens fontification — it's a large
  ;; chunk of the initial message burst.
  (eglot-ignored-server-capabilities
   '(:inlayHintProvider :semanticTokensProvider))
  :bind (("C-c d d" . flymake-show-diagnostics-buffer)    ; list all errors in buffer
         ("C-c d p" . flymake-show-project-diagnostics))   ; list errors across project
  :config
  ;; Belt-and-suspenders: ensure semantic tokens stay off per managed buffer.
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (when (fboundp 'eglot-semantic-tokens-mode)
                (eglot-semantic-tokens-mode -1))))
  ;; Language server registrations
  (add-to-list 'eglot-server-programs '(c3-ts-mode "c3-lsp"))
  (add-to-list 'eglot-server-programs '(odin-ts-mode "ols")))



;;;===== Dump Jump -(language aware definition and references without lsp) ---

(use-package dumb-jump
  :ensure nil ;; TODO: delete when fork branch is merged and avaialble in melpa
  :load-path "/home/ericus/code/dumb-jump" ;; fork with C3 support
  :custom
  (dumb-jump-prefer-searcher 'rg)
  (xref-show-definitions-function #'consult-xref)
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;;; ---- Keybinding Discovery -------------------------------------------------

(use-package which-key
  :ensure nil; built-in
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.5))

;;; ---- Git (Magit) ----------------------------------------------------------

(use-package magit
  :bind (("C-c g s" . magit-status)
         ("C-c g l" . magit-log-current)
         ("C-c g b" . magit-blame)))

;;; ---- Snippets (YASnippet) -------------------------------------------------

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets  ; community snippet collection
  :after yasnippet)

;;; ---- Move Lines -----------------------------------------------------------

(use-package move-text
  :config
  ;; Alt-j / Alt-k to move lines
  (global-set-key (kbd "M-n") 'move-text-down)
  (global-set-key (kbd "M-p") 'move-text-up))

;;; ---- Language Modes -------------------------------------------------------

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :custom
  (markdown-fontify-code-blocks-natively t)) ; syntax highlight fenced code blocks

(use-package yaml-mode
  :mode ("\\.ya?ml\\'"))

(use-package rust-mode
  :mode "\\.rs\\'")

(require 'rust-lspmux)
(add-hook 'rust-mode-hook      'eglot-ensure)

(use-package go-mode
  :mode "\\.go\\'")

(use-package lua-mode
  :mode "\\.lua\\'")

(use-package zig-mode
  :mode "\\.zig\\'")

(use-package c3-ts-mode
  :ensure nil
  :vc (:url "https://github.com/c3lang/c3-ts-mode" :branch "main" :rev :newest)
  :mode "\\.c3\\'"
  :config
  (add-to-list 'treesit-language-source-alist
               '(c3 "https://github.com/c3lang/tree-sitter-c3"))
  (unless (treesit-language-available-p 'c3)
    (treesit-install-language-grammar 'c3))
  (setq c3-ts-mode-indent-offset 4))
;;(add-hook 'c3-ts-mode-hook   'eglot-ensure) ;; lsp

(use-package odin-ts-mode
  :ensure nil
  :vc (:url "https://github.com/Sampie159/odin-ts-mode" :branch "main" :rev :newest)
  :mode "\\.odin\\'"
  :config
  (add-to-list 'treesit-language-source-alist
               '(odin "https://github.com/tree-sitter-grammars/tree-sitter-odin"))
  (unless (treesit-language-available-p 'odin)
    (treesit-install-language-grammar 'odin))
  ;; Odin compiler error format: /path/file.odin(16:3) Error: ...
  (add-to-list 'compilation-error-regexp-alist 'odin)
  (add-to-list 'compilation-error-regexp-alist-alist
               '(odin "\\(/[^(]+\\.odin\\)(\\([0-9]+\\):\\([0-9]+\\))" 1 2 3)))
;; (add-hook 'odin-ts-mode-hook   'eglot-ensure) ;; lsp

;; Local modes (from emacs/local/)
(require 'jai-mode)
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))
(add-to-list 'auto-mode-alist '("\\.[b]\\'" . simpc-mode))

;;; ---- Org Mode -------------------------------------------------------------
;; Org is built-in; this section just makes it look and behave nicely.

(use-package org
  :ensure nil ; built-in
  :hook
  ;; Soft-wrap lines in org buffers (global truncate-lines is t)
  (org-mode . visual-line-mode)
  ;; Disable electric-pair — it fights with org's own emphasis/bracket handling
  (org-mode . (lambda () (electric-pair-local-mode -1)))
  :custom
  (org-hide-leading-stars t)         ; show only one star per heading level
  (org-startup-indented t)           ; visually indent content under headings
  (org-hide-emphasis-markers t)      ; hide *bold* /italic/ markers, show styled text
  (org-return-follows-link t)        ; RET opens links
  (org-startup-folded 'content)      ; open files with headings visible, bodies folded
  (org-ellipsis " ▾")                ; nicer fold indicator (instead of "...")
  (org-pretty-entities t)            ; render \alpha, \beta, etc. as Unicode
  (org-fontify-quote-and-verse-blocks t)
  :config
  ;; Scale heading faces so they actually look like headings
  (set-face-attribute 'org-level-1 nil :height 1.3 :weight 'bold)
  (set-face-attribute 'org-level-2 nil :height 1.2 :weight 'bold)
  (set-face-attribute 'org-level-3 nil :height 1.1 :weight 'bold))

;; Reveal hidden markers (bold, links, etc.) only when cursor is on them.
;; In Evil: markers appear in Insert mode, hidden in Normal mode.
(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autoemphasis t)       ; reveal *bold* /italic/ markers
  (org-appear-autolinks t)          ; reveal [[link]] markup
  (org-appear-autosubmarkers t)     ; reveal sub/superscripts
  (org-appear-autoentities t)       ; reveal \alpha etc.
  (org-appear-trigger 'always))     ; reveal when cursor enters element

;;; ---- Compile Mode ---------------------------------------------------------
;; Built-in. Runs a shell command, parses output for file:line errors,
;; lets you jump to each error with next-error / previous-error.
;; project-compile runs from the project root (detected via project.el)

(global-set-key (kbd "C-c c b") 'compile)           ; compile from buffer
(global-set-key (kbd "C-c c c") 'project-compile)   ; compile from project root
(global-set-key (kbd "C-c c r") 'recompile)         ; re-run last compile
(global-set-key (kbd "M-g n")   'next-error)        ; jump to next error
(global-set-key (kbd "M-g p")   'previous-error)    ; jump to previous error

(setq compilation-scroll-output 'first-error) ; auto-scroll compilation buffer
(setq compilation-ask-about-save nil)         ; save files before compiling without asking
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter) ; render ANSI color codes

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
