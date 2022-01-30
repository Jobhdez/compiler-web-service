(in-package #:scheme-to-lambda-calculus)

(defun compile-scheme (scheme-expression)
  "
  compile a given SCHEME-EXPRESSION to the lambda calculus.
  "
  (cond ((integer-p scheme-expression)
	 (church-numeral scheme-expression))
	((zero-p scheme-expression)
	 `(,lambda-zerop ,(compile-scheme (zeroexp scheme-expression))))
	((true-p scheme-expression)
	 lambda-true)
	((false-p scheme-expression)
	 lambda-false)
	((and (symbolp scheme-expression) (or (not (eq scheme-expression 'ltrue)) (not (eq scheme-expression 'lfalse))))
	 scheme-expression)
	((ifp scheme-expression)
	   (compile-scheme `(,(getcond scheme-expression)
			     (lambda () ,(truef scheme-expression))
			     (lambda () ,(falsef scheme-expression)))))
	((and-p scheme-expression)
	 (compile-scheme `(if ,(leftexp scheme-expression)
			      ,(rightexp scheme-expression)
			    lfalse)))
	((subtractionp scheme-expression)
	 `((,sub ,(compile-scheme (leftexp scheme-expression)))
	  ,(compile-scheme (rightexp scheme-expression))))
	((additionp scheme-expression)
	 `((,add ,(compile-scheme (leftexp scheme-expression)))
	  ,(compile-scheme (rightexp scheme-expression))))
	 ((multiplicationp scheme-expression)
	  `((,mul ,(compile-scheme (leftexp scheme-expression)))
	    ,(compile-scheme (rightexp scheme-expression))))
	((equal-p scheme-expression)
	 (compile-scheme `(and (zero? (- ,(leftexp scheme-expression)
				              ,(rightexp scheme-expression)))
				 (zero? (- ,(rightexp scheme-expression)
					      ,(leftexp scheme-expression))))))
					      
	((quotep scheme-expression)
	 lambda-nil)
	((cons-p scheme-expression)
	 `((,lambda-cons ,(compile-scheme (leftexp scheme-expression)))
	   ,(compile-scheme (rightexp scheme-expression))))
	((carp scheme-expression)
	 `(,lambda-car ,(compile-scheme (car-exp scheme-expression))))
	((cdrp scheme-expression)
	 `(,lambda-cdr ,(compile-scheme (cdr-exp scheme-expression))))
	((nullp scheme-expression)
	 `(,lambda-null ,(compile-scheme (null-exp scheme-expression))))
	((lambdap scheme-expression)
	 (if (lambda-no-parametersp scheme-expression)
	     `(lambda () ,(compile-scheme (lambda-exp scheme-expression)))
	   `(lambda (,(lambda-parameter scheme-expression))
	      ,(compile-scheme (lambda-exp scheme-expression)))))
	((letp scheme-expression)
	 (compile-scheme `((lambda (,@(let-variable scheme-expression))
		      ,(let-body scheme-expression))
		    ,@(let-expression scheme-expression))))
	((letrecp scheme-expression)
	 (compile-scheme `(let ((,(letrec-variable scheme-expression)
			  (,Y (lambda (,(letrec-variable scheme-expression))
				,(letrec-expression scheme-expression)))))
		     ,(letrec-body scheme-expression))))
	((application-p scheme-expression)
	 (cond ((equalp (length scheme-expression) 1)
		(compile-scheme `(,(compile-scheme (car scheme-expression)) ,lambda-void)))
	       ((equalp (length scheme-expression) 2)
		`(,(compile-scheme (car scheme-expression))
		  ,(compile-scheme (car (cdr scheme-expression)))))
	       (t
		(compile-scheme `((,(car scheme-expression)
				   ,(car (cdr scheme-expression)))
				  ,(car (cdr (cdr scheme-expression))))))))
				 
	(t
	 "hello")))


(defvar lambda-void `(lambda (void) void))


(defvar lambda-error '(lambda ()
			 ((lambda (f) (f f)) (lambda (f) (f f)))))


(defvar lambda-true  `(lambda (t) (lambda (f) (t ,lambda-void))))
(defvar lambda-false `(lambda (t) (lambda (f) (f ,lambda-void))))

(defun church-numeral (n)
  (if (= n 0)
      `(lambda (f) (lambda (z) z))
    `(lambda (f) (lambda (z) ,(apply-n 'f n 'z)))))

(defun apply-n (f n z)
  (if (= n 0)
      z
    `(,f ,(apply-n f (- n 1) z))))


       

(defvar lambda-zerop `(lambda (n)
			((n (lambda () ,lambda-false)) ,lambda-true)))
                  
(defvar add '(lambda (n)
               (lambda (m)
                 (lambda (f)
                   (lambda (z)
                     ((m f) ((n f) z)))))))

(defvar mul '(lambda (n)
               (lambda (m)
                 (lambda (f)
                   (lambda (z)
                     ((m (n f)) z))))))
                     
(defvar pred '(lambda (n)
                (lambda (f)
                  (lambda (z)
                    (((n (lambda (g) (lambda (h) 
                                  (h (g f)))))
                      (lambda (u) z))
                     (lambda (u) u))))))

(defvar sub `(lambda (n)
               (lambda (m)
                 ((m ,pred) n))))



(defvar lambda-cons `(lambda (car)
		       (lambda (cdr)
			  (lambda (on-cons)
			     (lambda (on-nil)
				((on-cons car) cdr))))))

(defvar lambda-nil `(lambda (on-cons)
		      (lambda (on-nil)
			(on-nil ,lambda-void))))

(defvar lambda-car `(lambda (list)
		      ((list (lambda (car)
			       (lambda (cdr)
				 car)))
		       ,lambda-error)))

(defvar lambda-cdr `(lambda (list)
		      ((list (lambda (car)
			       (lambda (cdr)
				 cdr)))
		       ,lambda-error)))

"(defvar PAIR? `(λ (list)
                 ((list (λ (_) (λ (_) ,TRUE)))
                  (λ (_) ,FALSE))))"

(defvar lambda-nullp `(lambda (list)
			((list (lambda () (lambda () ,lambda-false)))
			 (lambda () ,lambda-true))))



(defvar Y '((lambda (y) (lambda (F) (F (lambda (x) (((y y) F) x))))) 
            (lambda (y) (lambda (F) (F (lambda (x) (((y y) F) x)))))))


(defun integer-p (exp)
  "Checks if EXP is an integer."
  (and (not (listp exp))
       (numberp exp)))

(defun zero-p (exp)
  "checks if EXP is a zero."
  (and (listp exp)
       (eq (car exp) 'zero?)))
(defun zeroexp (exp)
  (car (cdr exp)))

(defun subtractionp (exp)
  "checks if EXP is a subtraction."
  (and (listp exp)
       (equalp (car exp) '-)))

(defun additionp (exp)
  "checks if EXP is an addition."
  (and (listp exp)
       (equalp (car exp) '+)))

(defun multiplicationp (exp)
  "checks if EXP is a multiplication."
  (and (listp exp)
       (equalp (car exp) '*)))

(defun equal-p (exp)
  "checks if EXP is an equal-p."
  (and (listp exp)
       (equalp (car exp) '=)))

(defun quotep (exp)
  "Checks if EXP is a quote."
  (and (listp exp)
       (equalp (car exp) 'quote)))

(defun cons-p (exp)
  "Checks if EXP is a cons."
  (and (listp exp)
       (equalp (car exp) 'cons)))

(defun carp (exp)
  "Checks if EXP is a car."
  (and (listp exp)
       (equalp (car exp) 'car)))

(defun car-exp (exp)
  "get car's expression."
  (car (cdr exp)))

(defun cdrp (exp)
  "Checks if EXP is a cdr."
  (and (listp exp)
       (equalp (car exp) 'cdr)))

(defun cdr-exp (exp)
  "get cdr's exp."
  (car (cdr exp)))

(defun nullp (exp)
  "Checks if EXP is a null."
  (and (listp exp)
       (equalp (car exp) 'null)))

(defun null-exp (exp)
  "get null exp."
  (car (cdr exp)))

(defun letp (exp)
  "Checks if EXP is a let."
  (and (listp exp)
       (equalp (car exp) 'let)))

(defun let-variable (exp)
  "gets let's variable."
  (car (car (car (cdr exp)))))

(defun let-expression (exp)
  "gets let's expression"
  (car (cdr (car (car (cdr exp))))))

(defun let-body (exp)
  "gets let's body."
  (car (cdr (cdr exp))))

(defun letrecp (exp)
  "Checks if EXP is a letrec."
  (and (listp exp)
       (equalp (car exp) 'letrec)))

(defun letrec-variable (exp)
  "gets letrec's variable."
  (car (car (car (cdr exp)))))

(defun letrec-expression (exp)
  "gets letrec's expression"
  (car (cdr (car (car (cdr exp))))))

(defun letrec-body (exp)
  "gets letrec's body."
  (car (cdr (cdr exp))))



(defun lambdap (exp)
  "Checks if EXP is a lambda."
  (and (listp exp)
       (equalp (car exp) 'lambda)))

(defun lambda-parameter (exp)
  "gets the lambda parameter."
  (car (car (cdr exp))))

(defun lambda-exp (exp)
  "gets the lambda exp."
  (car (cdr (cdr exp))))

(defun leftexp (exp)
  "get the leftexp given an expression."
  (car (cdr exp)))

(defun rightexp (exp)
  "get the right exp given an expression."
  (car (cdr (cdr exp))))


(defun lambda-no-parametersp (exp)
  "check if the lambda expression contains 0 parameters."
  (and (listp exp)
       (null (car (cdr exp)))))

(defun lambda-parameter (exp)
  "gets the lambda paramater."
  (car (car (cdr exp))))

(defun lambda-exp (exp)
  "gets the lambda expression."
  (car (cdr (cdr exp))))

(defun application-p (exp)
  (listp exp))

(defun true-p (exp)
  (eq exp 'ltrue))

(defun false-p (exp)
  (eq exp'lfalse))

(defun ifp (exp)
  (and (listp exp)
       (equalp (car exp) 'if)))

(defun getcond (exp)
  (car (cdr exp)))

(defun truef (exp)
  (car (cdr (cdr exp))))

(defun falsef (exp)
  (car (cdr (cdr (cdr exp)))))

(defun and-p (exp)
  (and (listp exp)
       (eq (car exp) 'and)))
