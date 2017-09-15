(require 'just-utils)

(defconst PREETEST-PKG-FILE "preetest.pkg")
(defconst PREETEST-MAGIC-TEXT "PREETEST_PACKAGE")
(defconst PREETEST-QUESTION-DIR "questions/")
(defconst PREETEST-ANSWER-DIR "answers/")

(defconst PREETEST-QUESTION-DEFAULT
  "Create new question with pretest-new-question
   ###
   is delimiter.")

(defconst PREETEST-QUESTION-DELIMITER "###")

(defvar preetest-current-loc nil)
(defvar preetest-q-number 0)

(setq preetest-mode-map nil)
(setq preetest-mode-map (make-sparse-keymap))
(define-key preetest-mode-map "l" 'preetest-next-question)
(define-key preetest-mode-map "h" 'preetest-prev-question)
(define-key preetest-mode-map "g" 'preetest-navigate-question)
(define-key preetest-mode-map (kbd "RET") 'preetest-insert-answer)
(define-key preetest-mode-map "a" 'preetest-add-question)
(define-key preetest-mode-map "u" 'preetest-hide-answer)

(define-key preetest-mode-map (kbd "M-q s") 'preetest-show-answer)
(define-key preetest-mode-map (kbd "M-q e") 'preetest-edit-question)
(define-key preetest-mode-map (kbd "M-q x") 'preetest-delete-question)
(define-key preetest-mode-map (kbd "M-q c x") 'preetest-clear-answers)

(put 'preetest-mode 'mode-class 'special)

(define-derived-mode preetest-mode nil "Preetest"
  (use-local-map preetest-mode-map))

(evil-set-initial-state 'preetest-mode 'emacs)

(defun preetest-add-question ()
  (interactive)
  (when preetest-current-loc
   (preetest--add-question (1+ preetest-q-number) preetest-current-loc)
   (preetest-navigate-question (1+ preetest-q-number))
   (preetest-edit-question)))

(defun preetest-delete-question (confirm)
  (interactive "sAre you sure? (y or n)   ")
  (when preetest-current-loc
    (when (string-equal confirm "y")
      (preetest--navigate-question (1- preetest-q-number) preetest-current-loc)
      (preetest--delete-question (1+ preetest-q-number) preetest-current-loc))))

(defun preetest-next-question ()
  (interactive)
  (if preetest-current-loc
    (if (preetest--question-exists? (1+ preetest-q-number) preetest-current-loc)
      (preetest--navigate-question (1+ preetest-q-number) preetest-current-loc))))

(defun preetest-prev-question ()
  (interactive)
  (if preetest-current-loc
    (if (preetest--question-exists? (1- preetest-q-number) preetest-current-loc)
      (preetest--navigate-question (1- preetest-q-number) preetest-current-loc))))

(defun preetest-navigate-question (n)
  (interactive "nInsert question number... ")
  (if preetest-current-loc
    (preetest--navigate-question n preetest-current-loc)))

(defun preetest-insert-answer ()
  (interactive)
  (if preetest-current-loc
      (select-window-2)))

(defun preetest-edit-question ()
  (interactive)
  (if preetest-current-loc
      (preetest--edit-question preetest-q-number preetest-current-loc)))

(defun preetest-show-answer ()
  (interactive)
  (if preetest-current-loc
    (preetest--show-answer preetest-q-number preetest-current-loc)))

(defun preetest-hide-answer ()
  (interactive)
  (if preetest-current-loc
    (preetest--hide-answer preetest-q-number preetest-current-loc)))

(defun preetest-clear-answers (confirm)
  (interactive "sAre you sure? (y or n)   ")
  (when preetest-current-loc
    (when (string-equal confirm "y")
      (let ((loc (concat preetest-current-loc PREETEST-ANSWER-DIR)))
        (select-window-2)
        (switch-to-buffer (find-file (concat loc "0")))
        (dolist (i (number-sequence 1 (preetest--get-last loc)))
          (delete-file (concat loc (number-to-string i))))))))

(defun preetest-create-test ()
  (interactive)
  (let ((location (read-directory-name "Create test - Select location λ  ")))
    (preetest--create-test location)))

(defun preetest-open-test ()
  (interactive)
  (let ((location (read-directory-name "Open test - Select location λ  ")))
    (preetest--open-test location)))

(defun preetest-close-test ()
  (interactive)
  (select-window-1)
  (kill-buffer-and-window)
  (setq preetest-current-loc nil)
  (setq preetest-q-number 0))

(defun preetest-package? (location)
  (with-directory location
    (string-equal (get-string-from-file PREETEST-PKG-FILE)
                  PREETEST-MAGIC-TEXT)))

(defun preetest-update ()
  (interactive)
  (preetest--update preetest-q-number preetest-current-loc))

(defun preetest--update (n location)
  (with-directory location
    (select-window-2)
    (with-directory (concat location PREETEST-ANSWER-DIR)
      (let ((buf (current-buffer)))
        (save-buffer)
        (unless (file-exists-p (number-to-string n)) (create-file (number-to-string n)))
        (switch-to-buffer (find-file (number-to-string n)))
        (kill-buffer buf)))

    (select-window-1)
    (setq buffer-read-only nil)
    (rename-buffer (preetest--buffer-name n location))
    (erase-buffer)
    (with-directory (concat location PREETEST-QUESTION-DIR)
                    (insert (preetest--get-question n location)))
    (setq buffer-read-only t)))

(defun preetest--init (location)
  (with-directory location
    (select-window-1)
    (switch-to-buffer "temp")
    (setq buffer-read-only t)
    (toggle-truncate-lines 0)
    (setq truncate-partial-width-windows 0)
    (preetest-mode)

    (split-window-right)
    (select-window-2)
    (switch-to-buffer "tempr")

    (preetest--update 0 location)))

(defun preetest--edit-question (n location)
  (with-directory location
    (with-directory PREETEST-QUESTION-DIR
      (switch-to-buffer (find-file (number-to-string n))))))

(defun preetest--show-answer (n location)
  (select-window-1)
  (setq buffer-read-only nil)
  (erase-buffer)
  (insert (preetest--get-whole n location))
  (setq buffer-read-only t))

(defun preetest--hide-answer (n location)
  (select-window-1)
  (setq buffer-read-only nil)
  (erase-buffer)
  (insert (preetest--get-question n location))
  (setq buffer-read-only t))

(defun preetest--navigate-question (n location)
  (unless (= n preetest-q-number)
    (if (preetest--question-exists? n location)
        (preetest--change-q n location))))

(defun preetest--add-question (n location)
  (with-directory location
    (preetest--add-element n PREETEST-QUESTION-DIR)
    (preetest--add-element n PREETEST-ANSWER-DIR)))

(defun preetest--delete-question (n location)
  (with-directory location
    (preetest--remove-element n PREETEST-QUESTION-DIR)
    (preetest--remove-element n PREETEST-ANSWER-DIR)))

(defun preetest--question-exists? (n location)
   (with-directory location
     (with-directory PREETEST-QUESTION-DIR
       (file-exists-p (number-to-string n)))))

(defun preetest--create-test (location)
  (mkdir location)
  (with-directory location
    (with-temp-file PREETEST-PKG-FILE
      (insert PREETEST-MAGIC-TEXT))
    (mkdir PREETEST-QUESTION-DIR)
    (mkdir PREETEST-ANSWER-DIR)

    (with-temp-file (concat PREETEST-QUESTION-DIR "0")
      (insert PREETEST-QUESTION-DEFAULT))
    (create-file (concat PREETEST-ANSWER-DIR "0")))

  (preetest--open-test location))

(defun preetest--open-test (location)
  (with-directory location
    (unless (preetest-package? location) (error "Not a preetest test!"))
    (setq preetest-current-loc location)
    (preetest--init preetest-current-loc)))

(defun preetest--add-element (n location)
  (with-directory location
    (dolist (i (number-sequence (preetest--get-last (substring (pwd) 10)) n -1))
      (rename-file (number-to-string i) (number-to-string (1+ i))))
    (create-file (number-to-string n))))

(defun preetest--remove-element (n location)
  (with-directory location
    (delete-file (number-to-string n))
    (dolist (i (number-sequence (1+ n) (preetest--get-last (substring (pwd) 10))))
      (rename-file (number-to-string i) (number-to-string (1- i))))))

(defun preetest--change-q (n location)
  (setq preetest-q-number n)
  (preetest--update preetest-q-number location))

(defun preetest--get-last (dir)
  (seq-max (-map 'string-to-number (directory-files dir))))

(defun preetest--buffer-name (n location)
  (concat (file-name-nondirectory (directory-file-name (file-name-directory location)))
           " (" (number-to-string n) ")"))

(defun preetest--get-question (n location)
  (with-directory location
    (with-directory PREETEST-QUESTION-DIR
      (car (get-strings-from-file (number-to-string n) PREETEST-QUESTION-DELIMITER)))))

(defun preetest--get-whole (n location)
  (with-directory location
    (with-directory PREETEST-QUESTION-DIR
      (get-string-from-file (number-to-string n)))))

(provide 'preetest)
