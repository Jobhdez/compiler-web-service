(in-package #:scheme-to-lambda-calculus)

(defun compile-scheme (scheme-expression)
  "
  compiler a given SCHEME-EXPRESSION to the lambda calculus.
  "
  (cond ((integer-p scheme-expression)
	 (church-numeral scheme-expression))
	((zero-p scheme-expression)
	 `(,lambda-zerop ,(compile-scheme scheme-expression)))
	((true-p scheme-expression)
	 lambda-true)
	((false-p scheme-expression)
	 lambda-false)
	((and (symbolp scheme-expression) (or (not (eq scheme-expression 'ltrue)) (not (eq scheme-expression 'lfalse))))
	 scheme-expression)
	((ifp scheme-expression)
	 (let ((conds (getcond scheme-expression))
	       (tt (truef scheme-expression))
	       (ff (falsef scheme-expression)))
	   (compile-scheme `(,conds
			     (lamb () ,tt)
			     (lamb () ,ff)))))
	((and-p scheme-expression)
	 (compile-scheme `(if ,(leftexp scheme-expression)
			      ,(rightexp scheme-expression)
			    lambda-false)))
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
			x	 (zero? (- ,(rightexp scheme-expression)
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
	     `(lamb () ,(compile-scheme (lambda-exp scheme-expression)))
	   `(lamb (,(lambda-parameter scheme-expression))
	      ,(compile-scheme (lambda-exp scheme-expression)))))
	((letp scheme-expression)
	 (compile-scheme `((lamb (,@(let-variable scheme-expression))
		      ,(let-body scheme-expression))
		    ,@(let-expression scheme-expression))))
	((letrecp scheme-expression)
	 (compile-scheme `(let ((,(letrec-variable scheme-expression)
			  (,Y (lamb (,(letrec-variable scheme-expression))
				,(letrec-expression scheme-expression)))))
		     ,(letrec-body scheme-expression))))
	((applicationp scheme-expression)
	 (if (equalp (length scheme-expression) 1)
	     (compile-scheme `(,(compile-scheme f) ,lambda-void))
	   `(,(compile-scheme (leftexp scheme-expression))
	     ,(compile-scheme (rightexp scheme-expression)))))
	(t
	 "hello")))

; Void.
(defvar lambda-void `(λ (void) void))

; Error.
(defvar lambda-error '(λ (_) 
                 ((λ (f) (f f)) (λ (f) (f f)))))

; Booleans.
(defvar lambda-true  `(λ (t) (λ (f) (t ,lambda-void))))
(defvar lambda-false `(λ (t) (λ (f) (f ,lambda-void))))

; Church numerals.
(defun church-numeral (n)
  (cond
    ((= n 0)    `(λ (f) (λ (z) z)))
    (t      `(λ (f) (λ (z) 
                       ,(apply-n 'f n 'z))))))
(defun apply-n (f n z)
    (cond
      ((= n 0)  z)
      (t     `(,f ,(apply-n f (- n 1) z)))))
       

(defvar lambda-zerop `(lamb (n)
			 ((n (lamb () ,lambda-false)) ,lambda-true)))
                  
(defvar add '(λ (n)
               (λ (m)
                 (λ (f)
                   (λ (z)
                     ((m f) ((n f) z)))))))

(defvar mul '(λ (n)
               (λ (m)
                 (λ (f)
                   (λ (z)
                     ((m (n f)) z))))))
                     
(defvar pred '(λ (n)
                (λ (f)
                  (λ (z)
                    (((n (λ (g) (λ (h) 
                                  (h (g f)))))
                      (λ (u) z))
                     (λ (u) u))))))

(defvar sub `(λ (n)
               (λ (m)
                 ((m ,pred) n))))


; Lists.
(defvar lambda-cons `(λ (car) 
                (λ (cdr)
                  (λ (on-cons)
                    (λ (on-nil)
                      ((on-cons car) cdr))))))

(defvar lambda-nil `(λ (on-cons)
               (λ (on-nil)
                 (on-nil ,lambda-void))))

(defvar lambda-car `(λ (list)
               ((list (λ (car)
                       (λ (cdr)
                         car)))
                ,lambda-error)))

(defvar lambda-cdr `(λ (list)
               ((list (λ (car)
                       (λ (cdr)
                         cdr)))
                ,lambda-error)))

"(defvar PAIR? `(λ (list)
                 ((list (λ (_) (λ (_) ,TRUE)))
                  (λ (_) ,FALSE))))"

(defvar lambda-nullp `(λ (list)
                 ((list (λ (_) (λ (_) ,lambda-false)))
                  (λ (_) ,lambda-true))))


; Recursion.
(defvar Y '((λ (y) (λ (F) (F (λ (x) (((y y) F) x))))) 
            (λ (y) (λ (F) (F (λ (x) (((y y) F) x)))))))


(defun integer-p (exp)
  "Checks if EXP is an integer."
  (and (not (listp exp))
       (numberp exp)))

(defun zero-p (exp)
  "checks if EXP is a zero."
  (and (listp exp)
       (eq (car exp) 'zero?)))

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
       (equalp (car exp) 'quote)))

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
       (equalp (car exp) 'lamb)))

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

(defun applicationp (exp)
  (and (listp exp)
       (symbolp (car exp))))

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

(in-package #:scheme-to-lambda-calculus)
