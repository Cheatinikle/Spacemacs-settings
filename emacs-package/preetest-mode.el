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
;; (define-key preetest-mode-map "g" 'preetest-navigate-question)
(define-key preetest-mode-map "g" 'ignore)
(define-key preetest-mode-map (kbd "RET") 'preetest-insert-answer)

(put 'preetest-mode 'mode-class 'special)

(define-derived-mode preetest-mode nil "Preetest"
  (use-local-map preetest-mode-map))

(evil-set-initial-state 'preetest-mode 'emacs)

; TODO s
(defun preetest-next-question () undefined)
(defun preetest-prev-question () undefined)
(defun preetest-navigate-question () undefined)
(defun preetest-delete-question () undefined)
(defun preetest-edit-question () undefined)
(defun preetest-insert-answer () (interactive)(message "HI!"))

(defun preetest-check-answer () undefined)

;TODO - add opening question function.
(defun preetest-add-question ()
  (interactive)
  (preetest--add-question preetest-q-number preetest-current-loc))

(defun preetest-create-test ()
  (interactive)
  (let ((location (read-directory-name "Create test - Select location λ  ")))
    (preetest--create-test location)))

(defun preetest-open-test ()
  (interactive)
  (let ((location (read-directory-name "Open test - Select location λ  ")))
    (preetest--open-test location)))

(defun preetest-package? (location)
  (with-directory location
    (string-equal (get-string-from-file PREETEST-PKG-FILE)
                  PREETEST-MAGIC-TEXT)))

(defun preetest--update (n location)
  (with-directory location
    (select-window-1)
    (setq buffer-read-only nil)
    (rename-buffer (preetest--get-buffer-name n location))    
    (erase-buffer) ;TODO - is it right?
    (with-directory PREETEST-QUESTION-DIR
      (insert (preetest--get-question n)))   
    (setq buffer-read-only t)
    
    (select-window-2)
    (save-buffer) ; TODO - is it right?
    (with-directory PREETEST-ANSWER-DIR
        (switch-to-buffer (find-file (number-to-string n))))))

(defun preetest--init (location)
  (with-directory location
    (select-window-1)
    (switch-to-buffer "temp")
    (setq buffer-read-only t)
    (toggle-truncate-lines 0)
    (setq truncate-partial-width-windows 0)
    (preetest-mode)
    (split-window-right)

    (preetest--update 0 location)))

(defun preetest--navigate-question (n location)
  (unless (= n preetest-q-number)
    (preetest--change-q n location)))

(defun preetest--add-question (n location)
  (with-directory location
    (preetest--add-element n PREETEST-QUESTION-DIR)
    (preetest--add-element n PREETEST-ANSWER-DIR)))

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

    ;;(preetest-mode))
))

(defun preetest--add-element (n location)
  (with-directory location
    (dolist (i (number-sequence (preetest--get-last location) n -1))
      (rename-file (number-to-string i) (number-to-string (1+ i))))
    (create-file (number-to-string n))))

(defun preetest--remove-element (n location)
  (with-directory location
    (delete-file (number-to-string n))
    (dolist (i (number-sequence n (preetest--get-last location)))
      (rename-file (number-to-string i) (number-to-string (1- i))))))

(defun preetest--change-q (n location)
  (setq preetest-q-number n)
  (preetest--update n location))
  
(defun preetest--get-last (dir)
  (seq-max (-map 'string-to-number (directory-files dir))))

(defun preetest--buffer-name (n location)
  (concat (file-name-nondirectory (directory-file-name (file-name-directory location)))
           " (" (number-to-string n) ")"))

(defun preetest--get-question (n location)
  (with-directory location
    (with-directory PREETEST-QUESTION-DIR
      (get-strings-from-file (number-to-string n) PREETEST-QUESTION-DELIMITER)))

(provide 'preetest)
