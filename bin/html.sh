file=$1
emacs --batch -nw --no-init-file --no-site-file --find-file $file --eval "
(progn
  (require 'htmlize)
  (font-lock-mode 1)
  (let* ((htmlize-output-type 'css)
	 (output (replace-regexp-in-string \"code\" \"html\" (buffer-file-name)))
	 (htmlbuf (htmlize-region (point-min) (point-max))))
    (unwind-protect
	(with-current-buffer htmlbuf
          (make-directory (file-name-directory output) t)
	  (write-file (concat output \".html\") nil)))))
"