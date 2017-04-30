;; -*- lexical-binding: t -*- ;;

(defun macro-conc (&rest args)
  (intern (apply 'concat (mapcar 'symbol-name args))))

(defmacro if-nil (object default)
  (if object object default))

(defun if-empty (string default)
  (if (string= "" string) default string))

(defun compose (f g)
  (lambda (x) (funcall f (funcall g x))))

(defun <| (&rest fs)
  (-reduce 'function-compose fs))

(defun |> (&rest fs)
 (apply '<| (reverse fs)))

(defun swap (f)
  (lambda (y x) (apply-partially f x y)))

(funcall (funcall (apply-partially (swap '-) 2 ) 3) 4)




(funcall (|> '1+ (lambda (n) (* n 2)) (lambda (n) (* n n))) 1)

(funcall (|> '1+) 2)

(split-string "a  -> b" " -> ")

(provide 'just-utils)
