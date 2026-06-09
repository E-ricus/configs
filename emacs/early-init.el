;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Defer garbage collection during startup for faster load times.
;; Reset to a reasonable value after init (see end of init.el).
(setq gc-cons-threshold most-positive-fixnum)

;; Prevent package.el from loading packages before init.el runs.
;; We initialize package.el ourselves in init.el.
(setq package-enable-at-startup nil)

;; Redirect native-comp eln-cache to ~/.cache/emacs/ so it doesn't
;; pollute the config dir (which is a symlinked git repo).
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name "emacs/eln-cache/" (or (getenv "XDG_CACHE_HOME") "~/.cache")))))

;; Disable UI elements early — before the frame is drawn — to avoid flicker.
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars)  default-frame-alist)

;;; early-init.el ends here
