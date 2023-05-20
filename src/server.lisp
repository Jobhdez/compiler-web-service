(in-package #:lambda-server)

(defun start-server ()
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4243)))

(defmacro define-route (url view-fn compile-fn ht)
  `(define-easy-handler (,view-fn :uri ,url) (exp)
     (setf (content-type*) "application/json")
     (setf (header-out "Access-Control-Allow-Origin") "*")
     (setf *show-lisp-errors-p* t)
     (let* ((,ht (make-hash-table :test 'equal))
	    (e (list (read-from-string exp)))
	    (e2 `(,e))
	    (e3 (car (car e2)))
	    (expr (,compile-fn e3)))
       (setf (gethash 'expression ,ht) (write-to-string expr))
       (stringify ,ht))))

(defun compile-cps (e)
  (cps (desugar (parse-exp e)) 'halt))

(define-route "/compile" comp compile-scheme ht)
(define-route "/cps" cps* compile-cps cpsht)




