(in-package #:lambda-server)

;;; == compilation functions for handlers ==

(defun compile-cps (e)
  (cps (desugar (parse-exp e)) 'halt))

(defun identity* (e)
  e)

(defun read-str (e)
  (read-from-string e))

(defun compile-zetta (e)
  (let ((ast (parse-with-lexer (token-generator (lex-line e)) *python-grammar*)))
    (select-instructions (remove-complex-operands ast))))
