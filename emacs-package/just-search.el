;; -*- lexical-binding: t -*-

(defun macro-conc (&rest args)
  (intern (apply 'concat (mapcar 'symbol-name args))))

(defconst engines (make-hash-table :test 'equal) "Engine lists")

(cl-defmacro create-search-command (name &key input)
  "Given function with no argument that somehow gets user input keyword,  creates command with it."
  `(defun ,(macro-conc 'just-search- name) (engine)
     (interactive "sWhich engine to use? ")
     (let ((prefix (get-engine engine)))
       (if prefix (search-with prefix ,input)
         (message "Invalid engine!")))
     ))

(defmacro make-engine (name prefix)
  "Creates the function that searches given keyword with engine. Puts engine to engine lists"
  `(progn
     (defun ,(macro-conc 'just-search- name) ()
       (interactive)
       (search-with (get-engine ,(symbol-name name))))
     (puthash ,(symbol-name name) ,prefix engines)))

(defun get-engine (engine)
  "Gets engine frm engine lists"
  (gethash engine engines))


(create-search-command region :input 'keyword-from-region)
(create-search-command minibuffer)

(make-engine naver "https://search.naver.com/search.naver?where=nexearch&ie=utf8&query=")
(make-engine google "https://www.google.co.kr/#q=")
(make-engine stackoverflow "https://www.google.co.kr/#q=site:stackoverflow.com+")



(defun keyword-from-minibuffer ()
  "Gets keyword from minibuffer"
  (let ((default (thing-at-point 'symbol))
        (show-default (lambda (str) (if (string= "" str)
                                        "" (concat "default " str)))))
    (let ((keyword  (read-from-minibuffer
                     (format
                      "Insert keyword (%s) : " (funcall show-default default)))))
      (if (string= "" keyword) default keyword)
    )
  )
)

(defun keyword-from-region ()
  "Gets keyword from selected region"
  (let ((s (region-beginning)) (e (region-end)))
    (buffer-substring s e)))

(defun search-with (prefix &optional input)
  "Searches keyword with given input"
  (unless input (setf input 'keyword-from-minibuffer))
  (browse-url (concat prefix (funcall input)))
)

(provide 'just-search)


