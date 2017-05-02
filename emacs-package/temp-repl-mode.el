(require 'temp-repl)

(define-minor-mode temp-repl-mode
  "Temporary replacement"
  :init-value nil
  (if temp-repl-mode
    (progn
      (temp-repl-apply)
      (add-hook 'post-command-hook 'temp-repl-apply))
    (progn
      (remove-hook 'post-command-hook 'temp-repl-apply)
      (temp-repl-restore)))
  )

(provide 'temp-repl-mode)



