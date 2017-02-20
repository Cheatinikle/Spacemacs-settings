;; -*- lexical-binding: t -*-

(defun just-search (engine)
  (interactive "sWhich engine to use? ")
  (pcase engine
    ("google" (just-search-google))
    ("naver" (just-search-naver))
    ("stack" (just-search-stackoverflow))
    ("stackoverflow" (just-search-stackoverflow))
    (otherwise (message "Invalid engine."))))

(defun just-search-naver ()
  (interactive)
  (search-with "https://search.naver.com/search.naver?where=nexearch&ie=utf8&query="))

(defun just-search-google ()
  (interactive)
  (search-with "https://www.google.co.kr/#q="))

(defun just-search-stackoverflow ()
  (interactive)
  (search-with "https://www.google.co.kr/#q=site:stackoverflow.com+"))

(defun search-with (prefix)
  (command-execute (lambda (keyword)
    (interactive "sInsert keyword : ")
    (browse-url (concat prefix keyword))))
  )

(provide 'just-search)




