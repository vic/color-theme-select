;; Slate Color Theme for Emacs.
;;
;; Defines a colour scheme resembling that of the original TextMate Twilight colour theme.
;; To use add the following to your .emacs file (requires the color-theme package):
;;
;; (require 'color-theme)
;; (color-theme-initialize)
;; (load-file "~/.emacs.d/slate-emacs/color-theme-slate.el")
;;
;; And then (color-theme-slate) to activate it.
;;
;; Several areas still require improvement such as recognition of code that ruby-mode doesn't
;; yet pick up (eg. parent classes), Rails keywords, or non Ruby code related areas
;; (eg. dired, HTML, etc). Please feel free to customize further and send in any improvements,
;; patches most welcome.
;;
;; MIT License Copyright (c) 2009 Justin Smestad <crafterm@redartisan.com>
;; Credits due to the excellent MacVim Slate Color Theme

(require 'color-theme)

;;;###autoload
(defun color-theme-slate ()
  "Color theme by Justin Smestad, based off the VIM Slate theme, created 2009-06-29"
  (interactive)
  (color-theme-install
   '(color-theme-slate
     ((background-color . "grey15")
      (background-mode . dark)
      (border-color . "#c2bfa5")
      (cursor-color . "slategrey")
      (foreground-color . "#F8F8F8")
      (mouse-color . "sienna1"))
     (default ((t (:foreground "white"))))
     (blue ((t (:foreground "blue"))))
     (bold ((t (:bold t))))
     (bold-italic ((t (:bold t))))
     (border-glyph ((t (nil))))
     (buffers-tab ((t (:background "black" :foreground "white"))))
     (font-lock-builtin-face ((t (:foreground "white"))))
     (font-lock-comment-face ((t (:foreground "grey40"))))
     (font-lock-constant-face ((t (:foreground "#ffa0a0"))))
     (font-lock-doc-string-face ((t (:foreground "DarkOrange"))))
     (font-lock-function-name-face ((t (:foreground "navajowhite"))))
     (font-lock-keyword-face ((t (:foreground "gold"))))
     (font-lock-preprocessor-face ((t (:foreground "Aquamarine"))))
     (font-lock-reference-face ((t (:foreground "SlateBlue"))))
 
     (font-lock-regexp-grouping-backslash ((t (:foreground "#E9C062"))))
     (font-lock-regexp-grouping-construct ((t (:foreground "red"))))
 
     (font-lock-string-face ((t (:foreground "SkyBlue"))))
     (font-lock-type-face ((t (:foreground "CornflowerBlue"))))
     (font-lock-variable-name-face ((t (:foreground "#7587A6"))))
     (font-lock-warning-face ((t (:bold t :foreground "Pink"))))
     (gui-element ((t (:background "#303030" :foreground "black"))))
     (region ((t (:background "#444444"))))
     (mode-line ((t (:background "#303030" :foreground "black"))))
     (highlight ((t (:background "#222222"))))
     (highline-face ((t (:background "SeaGreen"))))
     (italic ((t (nil))))
     (left-margin ((t (nil))))
     (text-cursor ((t (:background "yellow" :foreground "black"))))
     (toolbar ((t (nil))))
     (underline ((nil (:underline nil))))
     (zmacs-region ((t (:background "snow" :foreground "ble")))))))

