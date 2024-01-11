(in-package #:lambda-server)

;;; == password and user store and session like store ==
(setf user-map 
      (make-hash-table
       :test #'equal
       :size 10000
       :rehash-size 10000
       :rehash-threshold 0.8
       :weakness nil
       :synchronized nil))

(setf auth-map (make-hash-table :test #'equal))

;;; == macros for handlers ==

(defmacro define-compilation (fn uri table compilation-fn fn*)
  `(define-easy-handler (,fn :uri ,uri) ()
     (setf (content-type*) "application/json")
     (setf (header-out "Access-Control-Allow-Origin") *)
     (setf *show-lisp-errors-p* t)
     (let* ((exp (post-parameter "exp"))
	    (username (post-parameter "user"))
	    (htable (make-hash-table :test 'equal))
	    (e (,fn* exp))
	    (re (,compilation-fn e))
	    (htable2 (make-hash-table :test 'equal)))
	    (if (find-dao 'user :username username)
		(progn (create-dao ',table :exp exp :user (find-dao 'user :username username) :eval-exp (write-to-string re))
		       (setf (gethash 'expression htable) (write-to-string re))
                       (stringify htable))
		(progn (setf (gethash 'response htable2) "Create an account")
		       (stringify htable2))))))


(defmacro define-exp (fn uri table compilation-fn fn*)
  `(define-easy-handler (,fn :uri ,uri) ()
     (setf (content-type*) "application/json")
     (setf (header-out "Access-Control-Allow-Origin") *)
     (setf *show-lisp-errors-p* t)

     (let* ((username (post-parameter "user"))
            (exp (post-parameter "exp"))
	    (e (,fn* exp))
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

;;; == definitions of handlers ==

(define-listing scm-exps "/scm-exps" scm-lambda-exp)
(define-listing cps-exps "/cps-exps" cps-exp)
(define-listing lalg-exps "/lalg-exps" lalg-exp)
(define-listing users "/users" user)
(define-listing py-exps "/py-exps" py-exp)

(define-exp-detail scm-exp "/scm-exp" scm-lambda-exp)
(define-exp-detail cps-exp "/cps-exp" cps-exp)
(define-exp-detail lalg-exp "/lalg-exp" lalg-exp)
(define-exp-detail py-exp "/py-exp" py-exp)

(define-compilation scm "/scm-compilations" scm-lambda-exp compile-scheme read-str)
(define-compilation cps "/cps-compilations" cps-exp compile-cps read-str)
(define-compilation py "/py-compilations" py-exp compile-zetta identity*)
(define-compilation lalg "/lalg-compilations" lalg-exp compile-yotta identity*)

(define-exp compiled-scm-exp "/compiled-scm-exps" scm-lambda-exp compile-scheme read-str)
(define-exp compiled-cps-exp "/compiled-cps-exps" cps-exp compile-cps read-str)
(define-exp compiled-zetta-exp "/compiled-py-exps" py-exp compile-zetta identity*)
(define-exp compiled-yotta-lalg "/compiled-lalg-exps" lalg-exp compile-yotta identity*)

(defmacro define-compile-expression (fn-name uri endpoint)
  `(define-easy-handler (,fn-name :uri ,uri) ()
    (setf (content-type*) "text/html")
    (format nil
	    "<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Expression Evaluator</title>
</head>
<body>
    <h2>Compiled Expression</h2>
    
    <label for=\"expressionInput\">Enter Expression:</label>
    <input type=\"text\" id=\"expressionInput\" placeholder=\"(if ltrue 2 3)\">
    
    <label for=\"userInput\">Enter User:</label>
    <input type=\"text\" id=\"userInput\" placeholder=\"compiler\">
    
    <button onclick=\"sendRequest()\">Compile Expression</button>
    
    <div id=\"response\"></div>

    <script>
        function sendRequest() {
            // Get values from input fields
            var expression = document.getElementById(\"expressionInput\").value;
            var user = document.getElementById(\"userInput\").value;
            // Create data object for POST request
            var data = new URLSearchParams();
            data.append(\"user\", user);
            data.append(\"exp\", expression);

            // Make POST request
            fetch('~A', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: data.toString()
            })
            .then(response => response.json())
            .then(data => {
                // Display server response
                document.getElementById(\"response\").innerHTML = 'Compiled Expression: ' + JSON.stringify(data);
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }
    </script>
   </body>" ,endpoint)))

(define-compile-expression compile-scm "/compile-scm" "http://localhost:4243/scm-compilations")
(define-compile-expression compile-cps "/compile-cps" "http://localhost:4243/cps-compilations")
(define-compile-expression compile-lalg "/compile-lalg" "http://localhost:4243/lalg-compilations")
(define-compile-expression compile-py "/compile-py" "http://localhost:4243/py-compilations")

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
