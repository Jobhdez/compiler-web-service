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
(setf user-map 
      (make-hash-table
       :test #'equal
       :size 10000
       :rehash-size 10000
       :rehash-threshold 0.8
       :weakness nil
       :synchronized nil))

(setf auth-map (make-hash-table :test #'equal))

(define-easy-handler (hello :uri "/hello") ()
  (format nil 
	  "<h4>hello</h4>"))

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


(defmacro define-exp (fn uri table compilation-fn)
  `(define-easy-handler (,fn :uri ,uri) ()
     (setf (content-type*) "application/json")
     (setf (header-out "Access-Control-Allow-Origin") *)
     (setf *show-lisp-errors-p* t)

     (let* ((username (post-parameter "user"))
            (exp (post-parameter "exp"))
	    (e (read-from-string exp))
	    (er (,compilation-fn e))
	    (htable (make-hash-table :test 'equal))
	    (htable2 (make-hash-table :test 'equal)))
       (if (gethash username auth-map)
	   (progn
             (create-dao ',table :exp exp :user (find-dao 'user :username username) :eval-exp (write-to-string er))
             (setf (gethash 'response htable) "Expressions Created!")
             (stringify htable))
	   (progn
	     (setf (gethash 'response htable2) "Must Be Logged in")
	     (stringify htable2))))))

(define-exp compiled-scm-exp "/compiled-scm-exps" scm-lambda-exp compile-scheme)

(defmacro define-listing (fn uri table)
  `(define-easy-handler (,fn :uri ,uri) ()
     (setf (content-type*) "application/json")
     (setf (header-out "Access-Control-Allow-Origin") "*")
     (setf *show-lisp-errors-p* t)
     (stringify (select-dao ',table))))

(defmacro define-exp-detail (fn uri table)
  `(define-easy-handler (,fn :uri ,uri) (id)
     (setf (content-type*) "application/json")
     (setf (header-out "Access-Control-Allow-Origin") "*")
     (setf *show-lisp-errors-p* t)
     (let ((htable (make-hash-table :test 'equal))
	   (exp (find-dao ',table :id id)))
       (setf (gethash 'detail htable) exp)
       (stringify htable))))


(define-listing scm-exps "/scm-exps" scm-lambda-exp)
(define-listing cps-exps "/cps-exps" cps-exp)
(define-listing lalg-exp "/lalg-exps" lalg-exp)
(define-listing users "/users" user)
(define-listing py-exps "/py-exps" py-exp)

(define-exp-detail scm-exp "/scm-exp" scm-lambda-exp)
(define-exp-detail cps-exps "/cps-exp" cps-exp)
(define-exp-detail lalg-exp "/lalg-exp" lalg-exp)
(define-exp-detail py-exps "/py-exps" py-exp)



;;index------
(hunchentoot:define-easy-handler (index :uri "/") (info)
  (setf (hunchentoot:content-type*) "text/html")
  (let ((the-user (hunchentoot:session-value :user)))
    (format nil 
	    "<h4>welcome-to-the-small-demo</h4><hr>
<p>info:~A</p>
<p>user:~A</p>
<a href=\"/sign-up\">click-here-to-sign-up</a><br>
<a href=\"/sign-in\">click-here-to-sign-in</a><br>
<a href=\"/sign-out\">click-here-to-sign-out</a><br>" info the-user)))

;;sign-up------
(hunchentoot:define-easy-handler (sign-up :uri "/sign-up") (info)
  (setf (hunchentoot:content-type*) "text/html")
  (format nil 
	  "<h4>welcome-to-sign-up</h4><hr>
<p>info:~A</p>
<a href=\"/\">click-here-to-index</a><br>
<form action=\"/sign-up-ok\" method=\"post\">
user:<br><input type=\"text\" name=\"user\" /><br>
pass:<br><input type=\"password\" name=\"pass\" /><br>
name:<br><input type=\"text\" name=\"name\" /><br>
email:<br><input type=\"text\" name=\"email\" /><br>
<input type=\"submit\" value=\"submit\" /></form>" info))

(hunchentoot:define-easy-handler (sign-up-ok :uri "/sign-up-ok") ()
  (setf (hunchentoot:content-type*) "text/plain")
  (let ((the-user   (hunchentoot:post-parameter "user"))
        (the-pass   (hunchentoot:post-parameter "pass"))
	(the-name   (post-parameter "name"))
	(the-email (post-parameter "email")))
    (if   (and  (stringp the-user) (stringp the-pass)
                (< 1 (length the-user) 200) (< 1 (length the-pass) 200))
          (if   (gethash the-user user-map)
                (hunchentoot:redirect "/sign-up?info=has-been-used")
                (progn
                  (setf (gethash the-user user-map) (cl-pass:hash the-pass))
		  (create-dao 'user :name the-name :username the-user :email the-email)
                  (hunchentoot:redirect "/sign-in")))                 
          (hunchentoot:redirect "/sign-up?info=input-error"))))

;;sign-in------
(hunchentoot:define-easy-handler (sign-in :uri "/sign-in") (info)
  (setf (hunchentoot:content-type*) "text/html")
  (if   (hunchentoot:session-value :user)
        (hunchentoot:redirect "/?info=you-had-sign-in")
        (format nil 
		"<h4>welcome-to-sign-in</h4><hr>
<p>info:~A</p>
<a href=\"/\">click-here-to-index</a><br>
<form action=\"/sign-in-ok\" method=\"post\">
user:<br><input type=\"text\" name=\"user\" /><br>
pass:<br><input type=\"password\" name=\"pass\" /><br>
<input type=\"submit\" value=\"submit\" /></form>" info)))

(hunchentoot:define-easy-handler (sign-in-ok :uri "/sign-in-ok") ()
  (setf (hunchentoot:content-type*) "text/plain")
  (let ((the-user   (hunchentoot:post-parameter "user"))
        (the-pass   (hunchentoot:post-parameter "pass")))
    (if   (and (stringp the-user) (stringp the-pass))
          (let ((pass-info (gethash the-user user-map)))
            (if   (ignore-errors (cl-pass:check-password the-pass pass-info))
                  (progn
                    (hunchentoot:start-session)
                    (setf (hunchentoot:session-value :user) the-user)
		    (setf (gethash the-user auth-map) the-user)
                    (hunchentoot:redirect "/?info=you-have-sign-in"))
                  (hunchentoot:redirect "/sign-in?info=password-error")))
          (hunchentoot:redirect "/sign-in?info=input-error"))))

;;sign-out------
(hunchentoot:define-easy-handler (sign-out :uri "/sign-out") ()
  (setf (hunchentoot:content-type*) "text/plain")
  (let ((the-user (session-value :user)))
    (progn
      (hunchentoot:remove-session hunchentoot:*session*)
      (remhash the-user auth-map)
      (hunchentoot:redirect  "/?info=you-had-sign-out"))))

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


