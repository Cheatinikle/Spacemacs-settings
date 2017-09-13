(require 'just-utils)

(defconst PREETEST-PKG-FILE "preetest.pkg")
(defconst PREETEST-MAGIC-TEXT "PREETEST_PACKAGE")
(defconst PREETEST-QUESTION-DIR "questions/")
(defconst PREETEST-ANSWER-DIR "answers/")

(defconst PREETEST-QUESTION-DEFAULT "Create new question with pretest-new-question")

(defconst PREETEST-QUESTION-DELIMITER "###")

(defvar preetest-current-loc nil)
(defvar preetest-q-number 0)

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

(defun preetest-add-question ()
  (interactive)
  (preetest--add-question preetest-q-number preetest-current-loc))

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

(defun preetest--get-last (dir)
  (seq-max (-map 'string-to-number (directory-files dir))))

(provide 'preetest)
