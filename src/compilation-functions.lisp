(in-package #:lambda-server)

;;; == compilation functions for handlers ==

(defun compile-cps (e)
  (cps (desugar (parse-exp e)) 'halt))
