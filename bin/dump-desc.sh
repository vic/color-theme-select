COLOR_THEMES=${1:-color-themes}
TARGET=${2:-themes.json}
DESC=${3:-"Themes from directory #{COLOR_THEMES}"}

files() {
    grep -H 'defun color-theme-' $COLOR_THEMES/*.el | sed -r -e "s/:.*defun\\s+/:/" -e "s/ \(.*$//" -e "s#(.*):(.*)#\2:\1#g" | sort -ft:
}

docstr() {
    t=$(tempfile)
    cat <<EOF > $t
(require 'json)
(message (concat "[" (json-join (mapcar 'json-encode-string (split-string (let (doc (or (documentation '$2)) "$2") "\n")) ", ") "]"))
EOF
    d=$(emacs --batch --no-site-file --no-init-file -l $1 -l $t 2>&1)    
    rm $t
    if [ "$d" == "Not enough arguments for format string" ]; then
	d="\"${2}\""
    fi
    echo $d
}

json(){
    file=$1
    name=$2
    short=$(echo $name | sed -re 's#color-theme-##g')
    t=$(tempfile)
    cat <<EOF > $t
(require 'json)
(require 'color-theme)
(defadvice color-theme-install (around is-dark (theme) activate)
  (setq ad-return-value (cdr (assoc 'background-mode (cadr theme))))
)
(defun color-theme-desc (name)
 (let ((doc (documentation '$name)))
   (if (and doc (not (or 
        (equal '$name 'color-theme-emacs-kingsajz)
        (equal '$name 'color-theme-emacs-nw))))
      (split-string doc "\n" t)
   (list (symbol-name name)))
 )
)
(let ((json (json-encode
  (list
    (cons "desc" (color-theme-desc '$name))
    (cons "mode" (or (${name}) "light"))
  )
)))

(message json)
)
EOF
    emacs --batch --no-site-file --no-init-file -l $1 -l $t 2>&1
    rm $t
}

echo -e "{\n" > $TARGET
for n in $(files); do
  f=$(echo $n | cut -d: -f 1)
  i=$(echo $n | cut -d: -f 2)
  echo "  \"$f\": $(json $i $f), " >> $TARGET
  echo $f
done
echo "  \"\": \"${DESC}\"" >> $TARGET
echo -e "\n}" >> $TARGET

