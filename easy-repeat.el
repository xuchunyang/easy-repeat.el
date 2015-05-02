;;; easy-repeat.el --- Repeat easily                 -*- lexical-binding: t; -*-

;; Copyright (C) 2015  Chunyang Xu

;; Author: Chunyang Xu <xuchunyang56@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "24.4"))
;; Keywords: repeat, convenience
;; Created: 2015-05-02
;; URL: https://github.com/xuchunyang/easy-repeat.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; `easy-repeat' enables you to easily repeat the previous command by using the
;; last short key, for example, 'C-x o' 'o' 'o' 'o'...  will switch windows
;; and 'M-x next-buffer RET' 'RET' 'RET' 'RET'... will switch buffers.

;; ## Setup

;;     (add-to-list 'load-path "/path/to/easy-repeat.el")
;;     (require 'easy-repeat)

;; ## Usage
;; Modify `easy-repeat-command-list' to choose which commands you want to repeat
;; easily.

;; To use: M-x easy-repeat-mode RET

;; ## TODO
;; - [ ] Drop Emacs 24.4 dependency for `advice-add' and `advice-remove'
;; - [ ] Set up a timer to free repeat key
;; - [ ] Allow shorter key, e.g., use single 'a' to repeat 'C-M-a'

;;; Code:

(defcustom easy-repeat-command-list
  '(other-window next-buffer backward-page forward-page)
  "List of commands for easy-repeat.
The term \"command\" here, refers to an interactively callable function."
  :type '(repeat (choice function))
  :group 'convenience)

(defun easy-repeat--repeat (orig-fun &rest args)
  (apply orig-fun args)
  (when (called-interactively-p 'interactive)
    (set-transient-map
     (let ((map (make-sparse-keymap)))
       (define-key map (vector last-command-event) #'repeat)
       map))))

(defun easy-repeat--add ()
  (dolist (command easy-repeat-command-list)
    (advice-add command :around #'easy-repeat--repeat)))

(defun easy-repeat--remove ()
  (dolist (command easy-repeat-command-list)
    (advice-remove command #'easy-repeat--repeat)))

;;;###autoload
(defun easy-repeat-add-last-command ()
  "Add the last command to `easy-repeat-command-list'."
  (interactive)
  (when (yes-or-no-p
         (format "Add '%s' to `easy-repeat-command-list'? " last-command))
    (add-to-list 'easy-repeat-command-list last-command)
    (easy-repeat-mode +1)))

;;;###autoload
(define-minor-mode easy-repeat-mode
  "Repeat easily.
Repeat by last short key, e.g., use 'o' to repeat 'C-x o'."
  :global t :group 'convenience
  (if easy-repeat-mode
      (easy-repeat--add)
    (easy-repeat--remove)))

(provide 'easy-repeat)

;;; easy-repeat.el ends here
