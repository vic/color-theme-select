(require 'json)
(require 'htmlize)
(require 'color-theme)

(defvar color-theme-print-output (or (getenv "DUMP_THEME_PRNT") (getenv "DUMP_THEME_PRINT")))
(defvar color-theme-json-output (getenv "DUMP_THEME_JSON"))
(defvar color-theme-lisp-output (getenv "DUMP_THEME_LISP"))
(defvar color-theme-html-output (getenv "DUMP_THEME_HTML"))

(defun color-theme-dump-print (theme output)
  (when output
    (save-excursion
      (let* ((outdir (file-name-directory output))
	     (name   (car theme))
	     (buff   (get-buffer-create "*elisp color theme*")))
	(color-theme-print buff)
	(switch-to-buffer buff)
	(goto-char (point-min))
	(replace-string "my-color-theme" name)
	(goto-line 2)
	(kill-line)
	(insert (or (and (documentation name) 
			 (format "\"%s\"" (documentation name)))
		    "nil"))
	(and outdir (make-directory outdir t))
	(write-file output nil)
	(fooo)
))))

(defun color-theme-dump-lisp (theme output)
  (when output
    (save-excursion
      (let* ((outdir (file-name-directory output))
	     (name   (car theme))
	     (buff   (get-buffer-create "*elisp color theme*")))
	(switch-to-buffer buff)
	(setq buffer-read-only nil)
	(erase-buffer)
	(print theme buff)
	(delete-backward-char 1)
	(insert "))")
	(goto-char (point-min))
	(delete-char 1)
	(insert "(defun " (symbol-name name) " ()"
		" \"" (or (documentation name) (symbol-name name)) "\""
		" (interactive) "
		" (color-theme-install '")
	(and outdir (make-directory outdir t))
	(write-file output nil)
))))


(defun color-theme-dump-html (theme output)
  (when output
    (save-excursion
      (let* ((outdir (file-name-directory output))
	     (name   (car theme))
	     (buff   (get-buffer-create "*elisp color theme*")))
	(switch-to-buffer buff)
	(setq buffer-read-only nil)
	(erase-buffer)
	(print theme buff)
	(delete-backward-char 1)
	(insert "))")
	(goto-char (point-min))
	(delete-char 1)
	(insert "(defun " (symbol-name name) " ()\n"
		" \"" (or (documentation name) (symbol-name name)) "\"\n"
		" (interactive)\n"
		" (color-theme-install '")
	(emacs-lisp-mode)
	(font-lock-mode 1)
	(switch-to-buffer (htmlize-buffer buff))
	(and outdir (make-directory outdir t))
	(write-file output nil)
))))

(defun color-theme-dump-json (theme output)
  (when output
    (save-excursion
      (let* ((outdir (file-name-directory output))
	     (name   (car theme))
	     (docs   (concat "[" 
			     (json-join (mapcar 'json-encode-string (split-string (or (documentation name) (symbol-name name)) "\n"))
					", ")
			     "]"))
	     (data   (json-encode theme))
	     (json   (concat "{"
			     "\"name\": " (json-encode name) ","
			     "\"docs\": " docs ","
			     "\"data\": " data 
			     "}"))
	     (buff   (get-buffer-create "*json color theme*")))
	(switch-to-buffer buff)
	(setq buffer-read-only nil)
	(erase-buffer)
	(insert json)
	(goto-char (point-min))
	(replace-string "null:" "\"null\":")
	(goto-char (point-min))
	(replace-string "true:" "\"true\":")
	(goto-char (point-min))
	(replace-string "false:" "\"false\":")
	(goto-char (point-min))
	(and outdir (make-directory outdir t))
	(write-file output nil)
))))

;; (defadvice json-encode-string (around color-name (str)  activate)
;;   (if (not (and (color-defined-p str) (not (equal (substring str 0 1) "#"))))
;;       ad-do-it
;;     (setq ad-return-value (concat "\"" (htmlize-color-to-rgb str) "\""))
;;   ))
  

(defadvice color-theme-install (around color-theme-json-dump (theme) activate)
  ad-do-it
  (when color-theme-json-output
    (color-theme-dump-json theme color-theme-json-output))
  (when color-theme-lisp-output 
    (color-theme-dump-lisp theme color-theme-lisp-output))
  (when color-theme-print-output 
    (unless window-system
      (error "Must execute this file with a display system to get color info.")
      (kill-emacs 1))
    (color-theme-dump-print theme color-theme-print-output))
  (when color-theme-html-output
    (unless window-system
      (error "Must execute this file with a display system to get color info.")
      (kill-emacs 1))
    (color-theme-dump-html theme color-theme-html-output))
)
