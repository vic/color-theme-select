;; color-theme-dirac: a pastel color theme for GNU Emacs
;; Copyright (C) 2010 Domenico Delle Side - domenico.delleside AT alcacoop.it

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <http://www.gnu.org/licenses/>.

(defun color-theme-dirac ()
  "Color theme Dirac - Domenico Delle Side (domenico.delleside AT alcacoop.it),
inspired by color-theme-galois."
  (interactive)
  (color-theme-install
   '(color-theme-dirac
     ((background-color . "black")
      (background-mode . dark)
      (border-color . "black")
      (cursor-color . "black")
      (foreground-color . "LightGray")
      (mouse-color . "black"))
     ((blank-space-face . blank-space-face)
      (blank-tab-face . blank-tab-face)
      (list-matching-lines-face . bold)
      (view-highlight-face . highlight))
     (default ((t (nil))))
     (blank-space-face ((t (:background "LightGray"))))
     (blank-tab-face ((t (:background "green" :foreground "black"))))
     (bold ((t (:bold t))))
     (bold-italic ((t (:italic t :bold t))))

     (font-lock-constant-face ((t (:foreground "#C17DF1"))))
     (font-lock-comment-face ((t (:italic t :foreground "dark slate blue"))))
     (font-lock-keyword-face ((t (:foreground "#F14D4F"))))
     (font-lock-preprocessor-face ((t (:italic t :foreground "HotPink"))))
     (font-lock-string-face ((t (:foreground "#92E683"))))
     (font-lock-variable-name-face ((t (:foreground "#93AAF2"))))
     (font-lock-function-name-face ((t (:italic t :foreground "#FFB774"))))
     (font-lock-type-face ((t (:foreground "#FFB774"))))
     (font-lock-warning-face ((t (:bold t :foreground "blue"))))

     ;; LaTeX faces
     (font-latex-math-face ((t (:foreground "#92E683"))))
     (font-latex-string-face ((t (:foreground "#92E683"))))
     (font-latex-italic-face ((t (:foreground "#92E683"))))
     (font-latex-bold-face ((t (:foreground "#92E683"))))
     (font-latex-verbatim-face ((t (:foreground "#92E683"))))

     (highlight ((t (:background "dark slate blue" :foreground "#93AAF2"))))
     (isearch ((t (:background "dim gray" :foreground "aquamarine"))))
     (ispell-face ((t (:bold t :background "#FFB774" :foreground "#92E683"))))
     (italic ((t (:italic t))))
     (menu ((t (:background "#304020" :foreground "navajo white"))))
     (modeline ((t (:background "dark slate blue" :foreground "LightGray"))))
     (modeline-mousable ((t (:background "light goldenrod" :foreground "dim gray"))))
     (modeline-mousable-minor-mode ((t (:background "dim gray" :foreground "light goldenrod"))))
     (region ((t (:background "dark slate gray" :foreground "#93AAF2"))))
     (secondary-selection ((t (:background "darkslateblue" :foreground "light goldenrod"))))
     (show-paren-match-face ((t (:background "turquoise" :foreground "black"))))
     (show-paren-mismatch-face ((t (:background "purple" :foreground "white"))))
     (underline ((t (:underline t))))
     (zmacs-region ((t (:background "dark slate gray" :foreground "#93AAF2")))))))