(in-package #:lambda-server)

;(defun start-server ()
 ; (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4243)))

(defvar *server*
  (make-instance 'hunchentoot:easy-acceptor
                 :port 4243))

(defun start-server ()
  (hunchentoot:start *server*))

(defun stop-server ()
  (hunchentoot:stop *server*))
                 ;:document-root (asdf:system-relative-pathname "compiler-web-service" "webbartleby/www/")))

;;; Launching in the browser:

;;; adopted from https://github.com/eudoxia0/trivial-open-browser, thank you
(defparameter +format-string+
  #+(or win32 mswindows windows)
  "explorer ~S"
  #+(or macos darwin)
  "open ~S"
  #-(or win32 mswindows macos darwin windows)
  "xdg-open ~S")

(defun open-browser (url)
  "Opens the browser to your target url"
  (uiop:run-program (format nil +format-string+ url)))

(defun launch ()
  (start-server)
  (uiop:run-program
   (format nil
           +format-string+
           "http://localhost:4243/compile?exp=(if (= 2 2) 2 3)")))


(define-easy-handler (scm :uri "/scm") ()
  (setf (content-type*) "application/json")
  (setf (header-out "Access-Control-Allow-Origin") *)
  (setf *show-lisp-errors-p* t)
  (let* ((exp (post-parameter "exp"))
	 (table (make-hash-table :test 'equal))
	 (e (read-from-string exp))
	 (re (compile-scheme e)))
    (setf (gethash 'expression table) (write-to-string re))
    (stringify table)))
	

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





;;; database

(defun connect-to-postgres ()
  (connect-toplevel :postgres :database-name "compiler" :username "compiler" :password "hello123"))

(connect-to-postgres)

(deftable user ()
  ((name :col-type (:varchar 64))
   (username :col-type (:varchar 100))
   (email :col-type (:varchar 128))))

(deftable lalg-exp ()
  ((exp :col-type :text)
   (user :col-type user)
   (eval-exp :col-type :text)))
  

(deftable cps-exp ()
  ((exp :col-type :text)
   (user :col-type user)
   (eval-exp :col-type :text)))


(deftable scm-lambda-exp ()
  ((exp :col-type :text)
   (user :col-type user)
   (eval-exp :col-type :text)))

(deftable py-exp ()
  ((exp :col-type :text)
   (user :col-type user)
   (eval-exp :col-type :text)))

(defun define-tables ()
  (mapcar #'table-definition '(user scm-lambda-exp lalg-exp cps-exp py-exp)))

(defun create-db-tables (table)
  (mapc #'execute-sql (table-definition table)))

(defun make-tables ()
  (mapcar #'create-db-tables '(user scm-lambda-exp lalg-exp cps-exp py-exp)))

(defun ensure-tables ()
  (mapcar #'ensure-table-exists '(user py-exp scm-lambda-exp lalg-exp cps-exp)))


