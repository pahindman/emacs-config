;; TODOs
;; - possibly use yasnippet
;; - why aren't comments auto-continuing in emacs-lisp code?
;; - implement more ideas from https://pavpanchekha.com/misc/emacs.html
;; - recursive grep - any extra configuration?
;; - minibufexplorer replacement -- probably not elscreen
;; - ctags integration

(package-initialize)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

(defun try-install-package (package)
   "Try to install and require the package.
If the package is already installed, then simply 'require' it.
Return t if installing and requiring the package succeeds, otherwise
return nil."
   (unless (package-installed-p package)
      (with-demoted-errors (package-install package)))
   (require package nil t))

(when (try-install-package 'evil-leader)
  (global-evil-leader-mode))

(when (try-install-package 'evil)
  (evil-mode 1)
  (setq-default evil-shift-width 3))

(when (try-install-package 'lua-mode)
   (autoload 'lua-mode "lua-mode" "Lua editing mode." t)
   (add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
   (add-to-list 'interpreter-mode-alist '("lua" . lua-mode)))

(when (try-install-package 'color-theme)
   (color-theme-initialize))

(when (try-install-package 'color-theme-solarized)
   (color-theme-solarized-dark))

(when (try-install-package 'company)
  (add-hook 'after-init-hook 'global-company-mode)
  (require 'color)
  (let ((bg (face-attribute 'default :background)))
    (custom-set-faces
      `(company-tooltip           ((t (:inherit default :background ,(color-lighten-name bg 8)))))
      `(company-scrollbar-bg      ((t (                 :background ,(color-lighten-name bg 22)))))
      `(company-scrollbar-fg      ((t (                 :background ,(color-lighten-name bg 15)))))
      `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
      `(company-tooltip-common    ((t (:inherit font-lock-constant-face)))))))

(try-install-package 'rainbow-mode)
(try-install-package 'magit)
(try-install-package 'p4)

(require 'ido)
(ido-mode t)

; when multiple buffers with the same name are loaded, use the parent
; directory names to uniquify the names
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

; don't use tabs for indenting
(setq-default indent-tabs-mode nil)
; tabs are as wide as 3 spaces
(setq-default tab-width 3)
; don't "word wrap" Lines
(setq-default truncate-lines t)
; visually indicate empty lines after the buffer end
(setq-default indicate-empty-lines t)

; always display the current buffer's name in the window/frame title
(setq frame-title-format "%b")

(setq make-backup-files nil)

; enable showing (LINE, COLUMN) in the mode line
(line-number-mode t)
(column-number-mode t)
; highlight the matching parenthesis when the closing one is typed
(show-paren-mode t)
; automatically indent code
(electric-indent-mode t)
; highlight the line that has point
(global-hl-line-mode t)

; delete extra whitespace at the end of lines
(add-hook 'before-save-hook 'delete-trailing-whitespace)
; but don't delete extra lines at the end of a file
(setq-default delete-trailing-lines nil)

;; CC mode configuration
(defvar ni-ss-style
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
  "The base style for ni-emacs.  Based on Systems Software standards.")

(require 'cc-mode)
(c-add-style "ni-ss" ni-ss-style)
(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "ni-ss")))

;; slime configuration
(add-to-list 'load-path "~/macports/share/emacs/site-lisp/slime")
(when (require 'slime-autoloads nil t)
   (setq slime-lisp-implementations
         `((clisp ("~/macports/bin/clisp"))))
   (slime-setup  '(slime-repl slime-asdf slime-fancy slime-banner)))

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
