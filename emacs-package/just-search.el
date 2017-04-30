;; -*- lexical-binding: t -*-

(require 'just-utils)

(defun search-with (prefix keyword)
  "Searches keyword with given prefix(search engine)"
  (browse-url (concat prefix keyword))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;;;

(defvar engines (make-hash-table :test 'equal) "Engine lists")

(defmacro make-engine (name prefix)
  "Creates the function that searches given keyword with engine. Puts engine to engine lists"
  `(progn
     (defun ,(macro-conc 'just-search- name) ()
       (interactive)
       (search-with (get-engine ,(symbol-name name)) (keyword-from-minibuffer)))
     (puthash ,(symbol-name name) ,prefix engines)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-engine (engine)
  "Gets engine frm engine lists"
  (gethash engine engines))

(cl-defmacro create-search-command (name &key input)
  "Given function with no argument that somehow gets user input keyword,  creates command with it."
  `(defun ,(macro-conc 'just-search- name) (engine)
     (interactive "sWhich engine to use? ")
     (let ((prefix (get-engine engine)))
       (if prefix
           (search-with prefix (funcall ,input))
         (message "Invalid engine!")))
     ))

(create-search-command region :input 'keyword-from-region)
(create-search-command minibuffer :input 'keyword-from-minibuffer)

(make-engine naver "https://search.naver.com/search.naver?where=nexearch&ie=utf8&query=")
(make-engine google "https://www.google.co.kr/#q=")
(make-engine stackoverflow "https://www.google.co.kr/#q=site:stackoverflow.com+")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun keyword-from-minibuffer ()
  (let ((default (thing-at-point 'symbol)))
    (if-empty
     (read-from-minibuffer
      (format "Insert keyword %s : "
              (if default (format "(default %s)" default) "")))
     default))
  )

(defun keyword-from-region ()
  "Gets keyword from selected region"
  (let ((s (region-beginning)) (e (region-end)))
    (buffer-substring s e)))

(provide 'just-search)
