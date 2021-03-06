;; -*- lexical-binding: t -*- ;;

(defun macro-conc (&rest args)
  (intern (apply 'concat (mapcar 'symbol-name args))))

(defmacro if-nil (object default)
  `(if ,object ,object ,default))

(defun if-empty (string default)
  (if (string= "" string) default string))

(defun compose (f g)
  (lambda (x) (funcall f (funcall g x))))

(defun <| (&rest fs)
  (-reduce 'compose fs))

(defun |> (&rest fs)
 (apply '<| (reverse fs)))

(defun swap (f)
  (lambda (y x) (apply-partially f x y)))

(defun funcall2 (&rest body)
  (funcall (apply 'funcall body)))

(defun funcall-p (f &rest args)
  (condition-case nil
      (apply f args)
    (wrong-number-of-arguments
      (apply 'apply-partially f args))))

(defmacro letw (&rest body)
  `(let ,(funcall (|> 'last 'cdar) body) ,@(butlast body)))

(defmacro with-directory (dir &rest body)
  (let ((srcdir (make-symbol "srcdir")))
    `(let ((,srcdir (substring (pwd) 10)))
       (prog2
         (cd ,dir)
         (progn ,@body)
         (cd ,srcdir)))))

(defun get-string-from-file (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

(cl-defun get-strings-from-file (filePath &optional (delimiter "\n"))
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) delimiter)))

(defun create-file (file)
  (write-region "" nil file))

(provide 'just-utils)
