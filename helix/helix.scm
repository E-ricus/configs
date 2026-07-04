;;; helix.scm — user-defined typable commands for the steel fork.
;;;
;;; Any `provide`d function here becomes a `:command` inside helix.
;;; Example (uncomment to try `:greet`):
;;;
;;;   (require (prefix-in helix.static. "helix/static.scm"))
;;;
;;;   (provide greet)
;;;   (define (greet)
;;;     (helix.static.set-status! "hello from steel"))

(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))
(require "helix/editor.scm")

(provide eval-sexpr)

;;@doc
;; Evaluate the s-expression underneath the cursor
(define (eval-sexpr)
  (define current-selection-object (helix.static.current-selection-object))
  (define current-selection (helix.static.current_selection))
  (define last-mode (editor-mode))
  (helix.static.match_brackets)
  (helix.static.select_mode)
  (helix.static.match_brackets)
  (eval-string (helix.static.current-highlighted-text!))
  (editor-set-mode! last-mode)
  (helix.static.set-current-selection-object! current-selection-object))


(define (git-status)
  (helix.run-shell-command "git" "status"))

