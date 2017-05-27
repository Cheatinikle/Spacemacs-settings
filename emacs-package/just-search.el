;; -*- lexical-binding: t -*-

(require 'just-utils)

(defun jsch/search-with (prefix keyword)
  "Searches keyword with given prefix.

   PREFIX : Url prefix. (such as \"http://google.co.kr/#q=\")
   KEYWORD : keyword you want to search.

   ex : (jsch/search-with \"http://google.co.kr/#q=\" \"lisp\")"

  (browse-url (concat prefix keyword)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:;;;;;;;;;;;;;;

(defvar jsch/engines (make-hash-table :test 'equal) "Engine dictionary")

(cl-defmacro jsch/create-search-command (name &key input engine)
  "A macro to create a keyword-searching function.
   NAME : name of the function you want to create.
   INPUT : function with no argument that returns string.
   ENGINE : function with no argument that returns string.
            (this string must be the name of predefined just-search engines)

   ex : (jsch/create-search-command test :input (lambda () \"lisp\")
                                         :engine (lambda () \"google\"))
        => just-search-test"

  `(defun ,(macro-conc 'just-search- name) ()
     (interactive)
     (let ((prefix (jsch/get-engine (funcall ,engine))))
       (if prefix
           (jsch/search-with prefix (funcall ,input))
           (message "Invalid engine!")))
     ))

(defmacro jsch/make-engine (name prefix)
  "Creates just-search engine. More exactly, creates a function that automatically searches given keyword and puts it to the just-search engine dictionary.

   NAME : name of the engine.
   PREFIX : Url prefix. (such as \"http://google.co.kr/#q=\")

   ex : (jsch/make-engine google \"http://google.co.kr/#q=\")"

  `(progn
     (jsch/create-search-command ,name :input 'jsch/keyword-from-anywhere
                                       :engine (lambda () ,(symbol-name name)))
     (puthash ,(symbol-name name) ,prefix jsch/engines)))

(defun jsch/get-engine (engine)
  "Gets engine from just-search engine dictionary.

   ENGINE : name of the engine (must be string type)

   ex : (jsch/get-engine \"google\") "

  (gethash engine jsch/engines))

(jsch/create-search-command region     :input 'jsch/keyword-from-region
                                       :engine (lambda () (read-from-minibuffer "Engine? ")))
(jsch/create-search-command minibuffer :input 'jsch/keyword-from-minibuffer
                                       :engine (lambda () (read-from-minibuffer "Engine? ")))
(jsch/create-search-command anywhere   :input 'jsch/keyword-from-anywhere
                                       :engine (lambda () (read-from-minibuffer "Engine? ")))

(jsch/make-engine naver "https://search.naver.com/search.naver?where=nexearch&ie=utf8&query=")
(jsch/make-engine google "https://www.google.co.kr/#q=")
(jsch/make-engine stackoverflow "https://www.google.co.kr/#q=site:stackoverflow.com+")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun jsch/keyword-from-minibuffer* (default)
  "Gets keyword from minibuffer.

   DEFAULT : default string to use when user inserted nothing to minibuffer."

  (if-empty
    (read-from-minibuffer
      (format "Insert keyword %s : "
              (if default (format "(default %s)" default) "")))
     default))

(defun jsch/keyword-from-minibuffer ()
  "Gets keyword from minibuffer (default = word currently pointing at)"

  (jsch/keyword-from-minibuffer* (thing-at-point 'symbol)))

(defun jsch/keyword-from-region ()
  "Gets keyword from selected region"

  (let ((s (region-beginning)) (e (region-end)))
    (buffer-substring s e)))

(defun jsch/keyword-from-anywhere ()
  "If something is selected, returns it. Otherwise, returns result of keyword-from-minibuffer"

  (if (region-active-p)
    (jsch/keyword-from-minibuffer* (jsch/keyword-from-region))
    (jsch/keyword-from-minibuffer)))

(provide 'just-search)
