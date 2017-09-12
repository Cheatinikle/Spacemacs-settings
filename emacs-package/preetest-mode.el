(require 'just-utils)

(defconst PREETEST-PKG-FILE "preetest.pkg")
(defconst PREETEST-MAGIC-TEXT "PREETEST_PACKAGE")
(defconst PREETEST-QUESTION-DIR "questions/")
(defconst PREETEST-ANSWER-DIR "answers/")

(defconst PREETEST-QUESTION-DEFAULT "Create new question with pretest-new-question")

(defconst PREETEST-QUESTION-DELIMITER "###")

(defvar preetest-current-loc nil)

(define-minor-mode preetest-mode
  "Create your own test"
  :init-value nil
  (if preetest-mode
      (progn
        (unless preetest-current-loc
          (preetest-open-test))))
  )

(defun preetest-create-test ()
  (interactive)
  (let ((location (read-file-name "Create test - Select location λ  ")))
    (preetest--create-test location)))

(defun preetest-open-test ()
  (interactive)
  (let ((location (read-file-name "Open test - Select location λ  ")))
    (preetest--open-test location)))

(defun preetest-package? (location)
  (cd location)
  (string-equal (get-string-from-file location) PREETEST-MAGIC-TEXT))

(defun preetest--create-test (location)
  (mkdir location)
  (cd location)
  (with-temp-file PREETEST-PKG-FILE
    (insert PREETEST-MAGIC-TEXT))
  (mkdir PREETEST-QUESTION-DIR)
  (mkdir PREETEST-ANSWER-DIR)
  
  (with-temp-file (concat PREETEST-QUESTION-DIR "0")
    (insert PREETEST-QUESTION-DEFAULT))
  ;TODO - correct into correct function.
  (create-file (concat PREETEST-ANSWER-DIR "0")

  (preetest--open-test location))

(defun preetest--open-test (location)
  (unless (preetest-package? location) (error "Not a preetest test!"))
  (setq preetest-current-loc location)

  (preetest-mode))

(provide 'preetest-mode)
