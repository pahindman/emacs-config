;; TODOs
;; - possibly use yasnippet
;; - why aren't comments auto-continuing in emacs-lisp code?
;; - implement more ideas from https://pavpanchekha.com/misc/emacs.html
;; - recursive grep - any extra configuration?
;; - minibufexplorer replacement -- probably not elscreen
;; - ctags integration
;; - turn electric indent back on once I get cc-mode squared away

(setq inhibit-startup-screen t)

(global-auto-revert-mode t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

(package-initialize)
(setq package-enable-at-startup nil)

(defun try-install-package (package)
   "Try to install and require the package.
If the package is already installed, then simply 'require' it.
Return t if installing and requiring the package succeeds, otherwise
return nil."
   (unless (package-installed-p package)
      (unless (assoc package package-archive-contents)
         (package-refresh-contents))
      (with-demoted-errors (package-install package)))
   (require package nil t))

(try-install-package 'req-package)

(req-package evil-surround
   :require evil
   :config (global-evil-surround-mode 1))

(req-package evil-leader
   :require evil
   :config
   (progn
      (global-evil-leader-mode 1)
      (evil-leader/set-leader ",")
      (evil-leader/set-key "*" 'rgrep)))

(req-package evil
   :require undo-tree
   :init
   (setq evil-search-module 'evil-search)
   :config
   (progn
      (evil-mode 1)
      (setq-default evil-shift-width 3)
      ; Remove RET and space from motion state map (j and l work just fine)
      (unbind-key "RET" evil-motion-state-map)
      (unbind-key " " evil-motion-state-map)
      ; make escape quit everything
      (bind-key "ESC" 'keyboard-quit evil-normal-state-map)
      (bind-key "ESC" 'keyboard-quit evil-visual-state-map)
      (evil-ex-define-cmd "tn" (lambda () (find-tag t)))
      (evil-ex-define-cmd "tp" (lambda () (find-tag '-')))
      (defun minibuffer-keyboard-quit ()
        "Abort recursive edit.
      In Delete Selection mode, if the mark is active, just deactivate it;
      then it takes a second \\[keyboard-quit] to abort the minibuffer."
        (interactive)
        (if (and delete-selection-mode transient-mark-mode mark-active)
            (setq deactivate-mark  t)
          (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
          (abort-recursive-edit)))
      (bind-key "ESC" 'minibuffer-keyboard-quit minibuffer-local-map)
      (bind-key "ESC" 'minibuffer-keyboard-quit minibuffer-local-ns-map)
      (bind-key "ESC" 'minibuffer-keyboard-quit minibuffer-local-completion-map)
      (bind-key "ESC" 'minibuffer-keyboard-quit minibuffer-local-must-match-map)
      (bind-key "ESC" 'minibuffer-keyboard-quit minibuffer-local-isearch-map)
      ; Evil doesn't auto-indent in insert mode by default
      (bind-key "RET" 'evil-ret-and-indent evil-insert-state-map)))

(req-package lua-mode
   :mode "\\.lua$"
   :interpreter "lua")

(req-package company
   :config (add-hook 'after-init-hook 'global-company-mode))

(req-package color-theme
   :config (color-theme-initialize))

(req-package color-theme-solarized
   :config (color-theme-solarized-dark))

(req-package rainbow-mode)
(req-package p4)

; when multiple buffers with the same name are loaded, use the parent
; directory names to uniquify the names
(req-package uniquify
  :config (setq uniquify-buffer-name-style 'forward))

; don't use tabs for indenting
(setq-default indent-tabs-mode nil)
; tabs are as wide as 3 spaces
(setq-default tab-width 3)
; don't "word wrap" Lines
(setq-default truncate-lines t)
; visually indicate empty lines after the buffer end
(setq-default indicate-empty-lines t)

; if the current buffer is visiting a file, display the file name in
; the window/frame title; otherwise display the buffer name
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

; put backups and auto-saves in folders under the .emacs.d folder
; TODO: replace .emacs.d with user-emacs-directory
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(add-to-list 'auto-save-file-name-transforms '(".*" "~/.emacs.d/auto-saves/\\2" t) t)

; Make underscore part of a word
(add-hook 'c-mode-common-hook #'(lambda() (modify-syntax-entry ?_ "w")))
(add-hook 'lisp-mode-hook     #'(lambda() (modify-syntax-entry ?_ "w")))
(add-hook 'makefile-mode-hook #'(lambda() (modify-syntax-entry ?_ "w")))
(add-hook 'package-mode-hook  #'(lambda() (modify-syntax-entry ?_ "w")))

; enable showing (LINE, COLUMN) in the mode line
(line-number-mode t)
(column-number-mode t)
; highlight the matching parenthesis when the closing one is typed
(show-paren-mode t)
; highlight the line that has point
(global-hl-line-mode t)
; disable toolbar buttons
(tool-bar-mode 0)
; scroll one line at a time (see docs for details)
(setq scroll-conservatively 10000)

(req-package grep
   :config
   ; Don't use find for recursive grep on windows
   (if (eq system-type 'windows-nt)
      (grep-apply-setting 'grep-find-command "grep -r")))

; delete extra whitespace at the end of lines
(add-hook 'before-save-hook 'delete-trailing-whitespace)
; but don't delete extra lines at the end of a file
(setq-default delete-trailing-lines nil)

; Don't ask about opening large files unless they are over 1GiB
(setq large-file-warning-threshold 1000000000)

; Switch to new tags table, rather than adding it to the list
(setq tags-add-tables nil)

; diff-mode is reprehensibly broken because it automatically modifies
; hunk headers in a way that consistently breaks them.
; The docs make it sound like that feature can be disabled by setting
; diff-update-on-the-fly to nil, but in that case it will still
; automatically break the hunk headers when the file is written.
; Thankfully, that can be worked around by overriding
; diff-write-content-hooks to do nothing.
(setq-default diff-update-on-the-fly nil)
(eval-after-load "diff-mode"
  '(defun diff-write-contents-hooks ()
     "Do nothing (rather than try to update diff hunk headers) when diff contents are written."
     nil))

;; CC mode configuration
(defvar phil-cc-style
  '( "bsd" ;; Base style
     (c-basic-offset . 3))
     ;(c-offsets-alist
     ; (statement            . 0)))
      ;(access-label        . -2)
      ;(substatement-open   . 0)
      ;(topmost-intro       . 0)
      ;(case-label          . +)
      ;(statement-case-open . 0)
      ;(innamespace         . 0)
      ;(cpp-define-intro    . c-lineup-cpp-define)
      ;(member-init-cont    . c-lineup-multi-inher)
      ;(stream-op           . c-lineup-streamop)
      ;(arglist-close       . c-lineup-arglist)))
  "Based on Systems Software standards.")

(req-package cc-mode
   :config
   (progn
      (c-add-style "phil" phil-cc-style)
      (setq c-default-style '((java-mode . "java")
                              (awk-mode . "awk")
                              (other . "phil")))))

(req-package rainbow-delimiters
   :config
   (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(req-package-finish)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-scrollbar-bg ((((class color) (min-colors 89)) (:background "#eee8d5" :foreground "#2aa198"))))
 '(company-scrollbar-fg ((((class color) (min-colors 89)) (:foreground "#fdf6e3" :background "#657b83"))))
 '(company-tooltip ((((class color) (min-colors 89)) (:background "#eee8d5" :foreground "#2aa198"))))
 '(company-tooltip-common ((((class color) (min-colors 89)) (:foreground "#586e75" :underline t))))
 '(company-tooltip-selection ((((class color) (min-colors 89)) (:background "#69CABF" :foreground "#00736F")))))
