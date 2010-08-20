#!/usr/bin/env sh
#
# Usage:
#
#   ./dump-light.sh [theme-name] [foreground] [background]
#
# This script helps generate base emacs color schemes.
# For example, there's no color-theme for the default emacs colors,
# so what this program does is, load an empty emacs, setting the
# foreground and background colors, then run a bunch of major modes
# and common emacs programs so that common faces get loaded, and
# finally generate a color theme.
#
# The three arguments are optionals and they default to
#    theme-name: color-theme-light
#    foreground: black
#    background: white
# 
# You could for example create a base theme for wheat bg like:
#
#  env DUMP_THEME_PRNT=demo.el ./dump-light.sh demo black wheat
# 
# Note: This program will do NOTHING IF no DUMP_THEME_* variable
# is present in environment. Read the docs in dump-theme.sh
#
export name=${1:-"color-theme-light"}
export foreground=${2:-"black"}
export background=${3:-"white"}
cmd="emacs --no-site-file --no-init-file -f toggle-debug-on-error $INIT -l site-lisp/dump-theme.el -l site-lisp/dump-light.el -f $name -f kill-emacs"
echo $cmd
exec $cmd