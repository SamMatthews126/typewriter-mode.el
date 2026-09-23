;;; typewriter-mode.el --- IBM Selectric mode for Emacs  -*- lexical-binding: t; -*-

;; Author: Sam Matthews <sam.matthews19638@gmail.com>
;; Maintainer: Sam Matthews <sam.matthews19638@gmail.com>
;; URL: https://github.com/SamMatthews126/typewriter-mode
;; Keywords: multimedia, convenience, typewriter
;; Version: 1.0

;; Copyright (C) 2026 Sam Matthews

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

;; This minor mode plays the sound of a typewriter as you type.
;; Originally based on selectric-mode by Ricardo Bánffy <rbanffy@gmail.com> at https://github.com/rbanffy/selectric-mode
;; Made changes to the sound files used and simplified the code a little bit
;; Also made it so the carriage return doesn't play whenever you move the cursor - only when you insert a new line

;;; Code:

(defconst typewriter-files-path (file-name-directory load-file-name)
  "Directory containing the typewriter audio files.")

(defvar-local typewriter-last-size nil
  "The last (buffer-size) seen by `typewriter-mode'.")

(defun typewriter-play (sound-file)
  "Play sound from file SOUND-FILE using platform-appropriate program."
  (let ((absolute-path (expand-file-name sound-file typewriter-files-path)))
		(cond
		  ((eq system-type 'windows-nt) (start-process "*Messages*" nil "powershell" "-c" (format "(New-Object Media.SoundPlayer '%s').PlaySync();" absolute-path)))
			((eq system-type 'darwin) (start-process "*Messages*" nil "afplay" absolute-path))
			(t (start-process "*Messages*" nil "aplay" absolute-path))))) ;Linux

(defun typewriter-type ()
  "Make the sound of the printing element hitting the paper."
  (if (= (current-column) (current-fill-column))
    (typewriter-play "bell.wav") ;Bell contains a typing sound so we don't need to play typing as well as the bell
    (typewriter-play "typing.wav")))

(defun typewriter-newline ()
  "Make the carriage movement sound."
  (typewriter-play "carriage-return.wav"))

(defun typewriter-post-command ()
  "Added to `post-command-hook' to decide what sound to play."
  (unless (minibufferp)
    (when (not (eql (buffer-size) typewriter-last-size))
			(if (and (eq (char-before (point)) ?\n) (> (buffer-size) typewriter-last-size))
        (typewriter-newline)
				(typewriter-type)))
		(setf typewriter-last-size (buffer-size))))

;;;###autoload
(define-minor-mode typewriter-mode
  "Toggle Typewriter mode.
When Typewriter mode is enabled, your Emacs will sound like an IBM
Typewriter typewriter."
  :global t
  :group 'typewriter
  (if typewriter-mode
      (add-hook 'post-command-hook 'typewriter-post-command)
    (remove-hook 'post-command-hook 'typewriter-post-command)))

(provide 'typewriter-mode)

;;; typewriter-mode.el ends here
