#!/usr/bin/env sh
# Dump an emacs color-theme to several formats: 
#
#  lisp: A lisp dump of the color theme.
#        Uses the theme object given to the
#        color-theme-install function.
#  json: A json file describing the color theme.
#        Uses the theme object given to the
#        color-theme-install function.
#  html: Htmlized version of lisp output
#  print: A lisp dump generated with color-theme-print
#         This version writes all faces, even those 
#         not present on the theme definition.
#
# Each output is activated by specifying the output
# file name in an environment variable. All env-vars
# are optional, and if none is present, nothing will be
# dumped.
#
#  DUMP_THEME_JSON
#  DUMP_THEME_LISP
#  DUMP_THEME_PRNT
#  DUMP_THEME_HTML
#
# Note: Dumping requires a display environment because
# dumping funciton use the color information from emacs
# runtime. LISP output simply dumps the object given to
# the color-theme-install function, so it will preserve
# data as is.
#
file=$1
func=$2
init=$3
exec emacs --no-site-file --no-init-file -f toggle-debug-on-error $init -l dump-theme.el -l $file -f $func -f kill-emacs
