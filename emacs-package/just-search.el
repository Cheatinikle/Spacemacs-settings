;; -*- lexical-binding: t -*-

(require 'just-utils)

(defun search-with (prefix keyword)
  "Searches keyword with given prefix.

   PREFIX : Url prefix. (such as \"http://google.co.kr/#q=\")
   KEYWORD : keyword you want to search.

   ex : (search-with \"http://google.co.kr/#q=\" \"lisp\")"

  (browse-url (concat prefix keyword)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;;;

(defvar engines (make-hash-table :test 'equal) "Engine lists")

(cl-defmacro create-search-command (name &key input engine)
  "A macro to create a keyword-searching function.
   NAME : name of the function you want to create.
   INPUT : function with no argument that returns string.
   ENGINE : function with no argument that returns string.
            (this string must be the name of predefined just-search engines)

   ex : (create-search-command test :input (lambda () \"lisp\")
                                    :engine (lambda () \"google\"))
        => just-search-test"

  `(defun ,(macro-conc 'just-search- name) ()
     (interactive)
     (let ((prefix (get-engine (funcall ,engine))))
       (if prefix
           (search-with prefix (funcall ,input))
         (message "Invalid engine!")))
     ))

(defmacro make-engine (name prefix)
  "Creates just-search engine. More exactly, creates a function that automatically searches given keyword and puts it to the just-search engine dictionary.

   NAME : name of the engine.
   PREFIX : Url prefix. (such as \"http://google.co.kr/#q=\")

   ex : (make-engine google \"http://google.co.kr/#q=\")"

  `(progn
     (create-search-command ,name :input 'keyword-from-anywhere
                                  :engine (lambda () ,(symbol-name name)))
     (puthash ,(symbol-name name) ,prefix engines)))

(defun get-engine (engine)
  "Gets engine from just-search engine dictionary.

   ENGINE : name of the engine (must be string type)

   ex : (get-engine \"google\") "

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
  "Gets keyword from minibuffer.

   DEFAULT : default string to use when user inserted nothing to minibuffer."

  (if-empty
    (read-from-minibuffer
      (format "Insert keyword %s : "
              (if default (format "(default %s)" default) "")))
     default))

(defun keyword-from-minibuffer ()
  "Gets keyword from minibuffer (default = word currently pointing at)"

  (keyword-from-minibuffer* (thing-at-point 'symbol)))

(defun keyword-from-region ()
  "Gets keyword from selected region"

  (let ((s (region-beginning)) (e (region-end)))
    (buffer-substring s e)))

(defun keyword-from-anywhere ()
  "If something is selected, returns it. Otherwise, returns result of keyword-from-minibuffer"

  (if (region-active-p)
    (keyword-from-minibuffer* (keyword-from-region))
    (keyword-from-minibuffer)))

(provide 'just-search)
