(require 'just-utils)

(defvar temp-repl--repl-lists (make-hash-table :test 'equal))
(defvar temp-repl--rest-lists (make-hash-table :test 'equal))

(defun temp-repl-in (htable)
  (-each (hash-table-keys htable)
    (lambda (key)
      (save-excursion
        (goto-char (point-min))
        (while (search-forward key nil t)
          (replace-match (gethash key htable))))))
  )

(defun temp-repl-apply ()
  (interactive)
  (temp-repl-in temp-repl--repl-lists))

(defun temp-repl-restore ()
  (interactive)
  (temp-repl-in temp-repl--rest-lists))

(defun temp-repl-add ()
  (interactive)
  (let ((from (read-from-minibuffer "From... "))
        (to (read-from-minibuffer "To... ")))
    (puthash from to temp-repl--repl-lists)
    (puthash to from temp-repl--rest-lists)))

(defun temp-repl-remove (target)
  (interactive "sWhat to remove?")
  (remhash (gethash target temp-repl--repl-lists) temp-repl--rest-lists)
  (remhash target temp-repl--repl-lists))

;; (defun temp-repl-remove-helm ()
;;   (interactive)
;;   (let ((source `((name . "Which to remove? ")
;;                   (candidates . ,(hash-table-keys temp-repl--repl-lists))
;;                   (action . (lambda (item) (temp-repl-remove item))))))
;;     (helm :sources '(source))))

(defun temp-repl-list ()
  (interactive)
  (let ((source `((name . "Temporary Replacing Lists")
                  (candidates . ,(-zip-with
                                  (lambda (a b) (concat a " -> " b))
                                  (hash-table-keys temp-repl--repl-lists)
                                  (hash-table-values temp-repl--repl-lists)))
                  (action . (("Add item" . ,(lambda (_) (progn (temp-repl-add) (temp-repl-list))))
                             ("Delete item" . ,(lambda (item) (progn (funcall (|> (lambda (x) (funcall2
                                                                                  (apply-partially (swap 'split-string) " -> ") x))
                                                                         'car
                                                                         'temp-repl-remove) item)
                                                                 (temp-repl-list))))
                             ("Clear lists" . ,(lambda (-) (progn (temp-repl-clear) (temp-repl-list)))))))))
    (helm :sources '(source))))


(defun temp-repl-clear ()
  (interactive)
  (clrhash temp-repl--repl-lists)
  (clrhash temp-repl--rest-lists))

;(add-hook 'kill-buffer-hook (lambda () (temp-repl-restore) (save-buffer)))

(provide 'temp-repl)

