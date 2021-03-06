;;; boon-keys.el --- An Ergonomic Command Mode  -*- lexical-binding: t -*-

;;; Commentary:

;; This module defines various keymaps and portions of keymaps, common
;; to all keyboard layouts.

;;; Code:

(require 'boon-core)

(defvar boon-goto-map (make-sparse-keymap))
(set-keymap-parent boon-goto-map goto-map)

(define-key boon-goto-map "l" 'goto-line)
(define-key boon-goto-map "." 'find-tag)

(define-key boon-x-map "x" 'execute-extended-command)

(define-key boon-select-map "@"  'boon-select-occurences)
(define-key boon-select-map "#"  'boon-select-all)
(define-key boon-select-map " "  'boon-select-line)
(define-key boon-moves-map  "'" 'boon-switch-mark)
(define-key boon-moves-map  (kbd "<left>") 'left-char)
(define-key boon-moves-map  (kbd "<right>") 'right-char)
(define-key boon-moves-map  (kbd "<up>") 'previous-line)
(define-key boon-moves-map  (kbd "<down>") 'next-line)

(define-key boon-command-map "'" 'boon-toggle-mark)
(define-key boon-command-map [(return)] 'undefined)
(define-key boon-command-map (kbd "<RET>") 'undefined)
(define-key boon-command-map [(backspace)] 'undefined)
(define-key boon-command-map "`" 'boon-toggle-case)

(define-key boon-command-map "!" 'shell-command)
(define-key boon-command-map "|" 'shell-command-on-region)
(define-key boon-command-map "-" 'undo)
(dolist (number '("0" "1" "2" "3" "4" "5" "6" "7" "8" "9"))
  (define-key boon-command-map number 'digit-argument))

(define-key boon-command-map " " 'boon-drop-mark)
(define-key boon-command-map [(escape)] 'boon-quit)

;; Special mode rebinds
(define-key boon-special-map "`" 'boon-quote-character)
(define-key boon-special-map "'" 'boon-quote-character)
(define-key boon-special-map "x" boon-x-map)

;; Off mode rebinds
(define-key boon-off-map [(escape)] 'boon-set-command-state)

;;  Insert mode rebinds
(define-key boon-insert-map [remap newline] 'boon-newline-dwim)
(define-key boon-insert-map [(escape)] 'boon-set-command-state)

;; Global rebinds
(define-key global-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key isearch-mode-map [escape] 'isearch-abort)

(defun boon-god-control-swap (event)
  "Swap the control 'bit' in EVENT, if that is a good choice."
  (interactive (list (read-key)))
  (cond
   ((memq event '(9 13 ?] ?[)) event)
   ((<= event 27) (+ 96 event))
   ((not (eq 0 (logand (lsh 1 26) event))) (logxor (lsh 1 26) event))
   (t (list 'control event))))

(defun boon-c-god ()
  "Input a key sequence, prepend C- to each key, and run the command bound to that sequence."
  (interactive)
  (let ((keys '((control c)))
        (binding (key-binding (kbd "C-c")))
        (key-vector (kbd "C-c"))
        (prompt "C-c-"))
    (while (and binding (not (symbolp binding)))
      (let ((key (read-key (format "%s" prompt))))
        (if (eq key ?h) (describe-bindings key-vector)
          (push (boon-god-control-swap key) keys)
          (setq key-vector (vconcat (reverse keys)))
          (setq prompt (key-description key-vector))
          (setq binding (key-binding key-vector)))))
    (setq this-command-keys key-vector)
    (cond
     ((not binding) (error "No command bound to %s" prompt))
     ((commandp binding) (call-interactively binding))
     (t (error "Key not bound to a command: %s" binding)))))

(provide 'boon-keys)
;;; boon-keys.el ends here
