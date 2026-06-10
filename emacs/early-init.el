;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Defer garbage collection during startup for faster load times.
;; Reset to a reasonable value after init (see end of init.el).
(setq gc-cons-threshold most-positive-fixnum)

;; Prevent package.el from loading packages before init.el runs.
;; We initialize package.el ourselves in init.el.
(setq package-enable-at-startup nil)

;; Disable UI elements early — before the frame is drawn — to avoid flicker.
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars)  default-frame-alist)

;;; early-init.el ends here
