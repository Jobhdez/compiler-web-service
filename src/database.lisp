(in-package #:lambda-server)

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
"""
(define-tables)
(make-tables)
(ensure-tables)
"""
