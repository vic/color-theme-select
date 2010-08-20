;;;;;; obtain parameters
(setq color-theme-name (or (getenv "name") "color-theme-light"))
(set-foreground-color (or (getenv "foreground") "black"))
(set-background-color (or (getenv "background") "white"))


;;;;;; Load a bunch of modes to obtain faces from them
(require 'color-theme)
(require 'ido)
(require 'htmlize)
(font-lock-mode 1)
(ido-mode)
(org-mode)
(java-mode)
(c-mode)
(perl-mode)
(python-mode)
(ruby-mode)
(xml-mode)
(dired "/")
(man "emacs")
(fundamental-mode)
(diff-mode)
(info "emacs")
(mail)
(eshell)
(speedbar)
(customize)
(set-face-attribute (intern "info-xref-visited") nil :inherit nil)


;; This should be the last thing to do
(list-faces-display)



;;;;;;;; Generate the theme
(color-theme-print)
(goto-char (point-min))
(replace-string "my-color-theme" color-theme-name)
(eval-buffer)

