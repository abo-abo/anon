;;; noprefix.el --- strip/dress namespace prefix from Elisp package.

;; Copyright (C) 2014 Oleh Krehel

;; Author: Oleh Krehel <ohwoeowho@gmail.com>
;; URL: https://github.com/abo-abo/noprefix
;; Version: 0.0.1
;; Keywords: lisp

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

(defvar noprefix-bare nil
  "If this is t, `noprefix-dress' should be called before eval.")
(make-variable-buffer-local 'noprefix-bare)

(defun noprefix-strip (&optional ext)
  "Strip package prefix EXT in file."
  (interactive)
  (let* ((name (or ext
                   (file-name-sans-extension
                    (file-name-nondirectory
                     (buffer-file-name)))))
         (regex (format "\\_<\\(%s-\\)[^])} \t]" name)))
    (save-excursion
      (atomic-change-group
        (goto-char (point-min))
        (while (re-search-forward regex nil t)
          (unless (save-excursion
                    (backward-char 1)
                    (lispy--in-string-or-comment-p))
            (replace-match "-" nil nil nil 1)))
        (when (called-interactively-p 'any)
          (save-buffer))
        (setq noprefix-bare t)))))

(defun noprefix-dress (&optional ext)
  "Add package prefix EXT in file."
  (interactive)
  (let* ((name (or ext
                   (file-name-sans-extension
                    (file-name-nondirectory
                     (buffer-file-name)))))
         (rep (concat name "-"))
         (regex "\\_<\\(-\\)[^]0-9 )}\"]"))
    (save-excursion
      (atomic-change-group
        (goto-char (point-min))
        (while (re-search-forward regex nil t)
          (unless (save-excursion
                    (backward-char 1)
                    (lispy--in-string-or-comment-p))
            (replace-match rep nil nil nil 1)))
        (when (called-interactively-p 'any)
          (save-buffer))
        (setq noprefix-bare nil)))))

(defadvice eval-buffer (around noprefix-eval-buffer activate)
  "Translate before evaluating."
  (if noprefix-bare
      (progn
        (noprefix-dress)
        ad-do-it
        (noprefix-strip))
    ad-do-it))

(provide 'noprefix)
