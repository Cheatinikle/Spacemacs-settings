;; -*- lexical-binding: t -*-

;; Engine hash table

(setq engines (create-hash-table
               '(("naver" "https://search.naver.com/search.naver?where=nexearch&ie=utf8&query=")
                 ("google" "https://www.google.co.kr/#q=")
                 ("stackoverflow"  "https://www.google.co.kr/#q=site:stackoverflow.com+"))))

(defun create-hash-table (hashes)
  (let ((table (make-hash-table :test 'equal)))
    (loop for hash in hashes do
          (puthash (first hash) (second hash) table))
    table)
  )

(defun get-engine (engine)
  (gethash engine engines))

;; Major just-search functions

(defun just-search-region (engine)
  (interactive "sWhich engine to use? ")
  (let ((prefix (get-engine engine)))
    (if prefix (search-with prefix 'keyword-from-region)
      (message "Invalid engine!")))
  )

(defun just-search (engine)
  (interactive "sWhich engine to use? ")
  (let ((prefix (get-engine engine)))
    (if prefix (search-with prefix)
      (message "Invalid engine!"))))

;; Minor just-search functions
(defun just-search-naver ()
  (interactive)
  (search-with (get-engine "naver")))

(defun just-search-google ()
  (interactive)
  (search-with (get-engine "google")))

(defun just-search-stackoverflow ()
  (interactive)
  (search-with (get-engine "stackoverflow")))

;; keyword-from functions
(defun keyword-from-minibuffer ()
  (let ((default (thing-at-point 'symbol))
        (show-default (lambda (str) (if (string= "" str)
                                        "" (concat "default " str)))))
    (read-from-minibuffer
     (format "Insert keyword (%s) : " (funcall show-default default)))
    )
  )

(defun keyword-from-region ()
  (let ((s (region-beginning)) (e (region-end)))
    (buffer-substring s e)))

;; search-with
(defun search-with (prefix &optional input)
  (if (null input) (setf input 'keyword-from-minibuffer))
  (let ((keyword (funcall input)))
    (if (string= "" keyword)
        (browse-url (concat prefix default))
      (browse-url (concat prefix keyword)))
    )
  )

(provide 'just-search)


