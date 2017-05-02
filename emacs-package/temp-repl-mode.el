(require 'temp-repl)

(define-minor-mode temp-repl-mode
  "Temporary replacement"
  :init-value nil
  (if temp-repl-mode
    (progn
      (temp-repl-apply-to-buffer)
      (add-hook 'post-command-hook 'temp-repl-apply-to-word))
    (progn
      (remove-hook 'post-command-hook 'temp-repl-apply-to-word)
      (temp-repl-restore-buffer)))
  )

(provide 'temp-repl-mode)



