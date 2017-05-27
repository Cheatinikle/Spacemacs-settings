;; -*- lexical-binding: t -*-

(require 'just-utils)

(defun search-with (prefix keyword)
  "Searches keyword with given prefix(search engine)"
  (browse-url (concat prefix keyword))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;;;

(defvar engines (make-hash-table :test 'equal) "Engine lists")

(cl-defmacro create-search-command (name &key input engine)
  "Given function with no argument that somehow gets user input keyword,  creates command with it."
  `(defun ,(macro-conc 'just-search- name) ()
     (interactive)
     (let ((prefix (get-engine (funcall ,engine))))
       (if prefix
           (search-with prefix (funcall ,input))
         (message "Invalid engine!")))
     ))

(defmacro make-engine (name prefix)
  "Creates the function that searches given keyword with engine. Puts engine to engine lists"
  `(progn
     (create-search-command ,name :input 'keyword-from-anywhere
                                 :engine (lambda () ,(symbol-name name)))
     (puthash ,(symbol-name name) ,prefix engines)))

(defun get-engine (engine)
  "Gets engine frm engine lists"
  (gethash engine engines))

(create-search-command region     :input 'keyword-from-region
                                  :engine (lambda () (read-from-minibuffer "Engine? ")))
(create-search-command minibuffer :input 'keyword-from-minibuffer
                                  :engine (lambda () (read-from-minibuffer "Engine? ")))
(create-search-command anywhere   :input 'keyword-from-anywhere
                                  :engine (lambda () (read-from-minibuffer "Engine? ")))

(make-engine naver "https://search.naver.com/search.naver?where=nexearch&ie=utf8&query=")
(make-engine google "https://www.google.co.kr/#q=")
(make-engine stackoverflow "https://www.google.co.kr/#q=site:stackoverflow.com+")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun keyword-from-minibuffer* (default)
  (if-empty
    (read-from-minibuffer
      (format "Insert keyword %s : "
              (if default (format "(default %s)" default) "")))
     default))

(defun keyword-from-minibuffer ()
  (keyword-from-minibuffer* (thing-at-point 'symbol)))

(defun keyword-from-region ()
  "Gets keyword from selected region"
  (let ((s (region-beginning)) (e (region-end)))
    (buffer-substring s e)))

(defun keyword-from-anywhere ()
  (if (region-active-p)
    (keyword-from-minibuffer* (keyword-from-region))
    (keyword-from-minibuffer)))

(provide 'just-search)
