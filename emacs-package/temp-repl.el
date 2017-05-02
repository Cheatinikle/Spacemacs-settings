(require 'just-utils)

(defvar temp-repl--apply-to-minibuffer t)
(defvar temp-repl--disable-removing-if-mode-on t)

(defvar temp-repl--repl-lists (make-hash-table :test 'equal))
(defvar temp-repl--rest-lists (make-hash-table :test 'equal))

(defun temp-repl-in-region (beginning end htable)
  (unless (and (not temp-repl--apply-to-minibuffer) (minibufferp))
    (-each (hash-table-keys htable)
      (lambda (key)
        (save-excursion
          (goto-char beginning)
          (while (and (search-forward key nil t) (<= (point) end))
            (replace-match (gethash key htable))))))))

(defun temp-repl-in-buffer (htable)
  (temp-repl-in-region (point-min) (point-max) htable))

(defun temp-repl-in-word (htable)
  (let ((beginning (car (bounds-of-thing-at-point 'word)))
        (end (cdr (bounds-of-thing-at-point 'word))))
    (if (and beginning end) (temp-repl-in-region beginning end htable))))

(defun temp-repl-apply-to-buffer ()
  (interactive)
  (temp-repl-in-buffer temp-repl--repl-lists))

(defun temp-repl-restore-buffer ()
  (interactive)
  (temp-repl-in-buffer temp-repl--rest-lists))

(defun temp-repl-apply-to-word ()
  (interactive)
  (temp-repl-in-word temp-repl--repl-lists))

;; (defun temp-repl-restore-word ()
;;   (interactive)
;;   (temp-repl-in-word temp-repl--rest-lists))


(defun temp-repl--restore-and-kill-buffer ()
  (interactive)
  (temp-repl-restore)
  (kill-buffer))


(defun temp-repl-add (&optional from to)
  (interactive)
  (let ((from (if-nil from (read-from-minibuffer "From... ")))
        (to (if-nil to (read-from-minibuffer "To... "))))
    (puthash from to temp-repl--repl-lists)
    (puthash to from temp-repl--rest-lists)))

(defun temp-repl-remove (target)
  (when (and temp-repl-mode temp-repl--disable-removing-if-mode-on)
    (error "Error : Please disable temp-repl mode"))
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
  (when (and temp-repl-mode temp-repl--disable-removing-if-mode-on)
    (error "Error : Please disable temp-repl mode"))
  (interactive)
  (clrhash temp-repl--repl-lists)
  (clrhash temp-repl--rest-lists))


;(add-hook 'kill-buffer-hook (lambda () (temp-repl-restore) (save-buffer)))

(provide 'temp-repl)

