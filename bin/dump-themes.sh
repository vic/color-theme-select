COLOR_THEMES=${1:-site-lisp/themes}
TARGET=${2:-public/themes}

files() {
    grep -H 'defun color-theme-' $COLOR_THEMES/*.el | 
    sed -r -e "s/:.*defun\\s+/:/" -e "s/ \(.*$//" -e "s#(.*):(.*)#\2:\1#g" | 
    sort -ft:
}

for n in $(files); do
  f=$(echo $n | cut -d: -f 1)
  i=$(echo $n | cut -d: -f 2)

  export DUMP_THEME_JSON=$TARGET/json/$f.json
  export DUMP_THEME_LISP=$TARGET/el/$f.el
  emacs --no-site-file --no-init-file -f toggle-debug-on-error -l site-lisp/dump-theme.el -l $i -f $f -f kill-emacs
  echo $f

done
