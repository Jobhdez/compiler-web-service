(defun compile (scheme-expression)
  "compile a given SCHEME-EXPRESSION to the lambda calculus."
  (cond ((integerp scheme-expression)
	 (church-numeral scheme-expression))
	((zerop scheme-expression) (lambda-zerop scheme-expression))
	((subtractionp scheme-expression)
	 `((,sub ,(compile (leftexp scheme-expression)))
	  ,(compile rightexp)))
	((additionp scheme-expression)
	 `((,add ,(compiler (leftexp scheme-expression)))
	  ,(compile (rightexp scheme-expression))))
	 ((multiplicatiop scheme-expression)
	 `((,mul ,(compiler (leftexp scheme-expression)))
	 , (compile (rightexp scheme-expression))))
	((equal-p scheme-expression)
	 (compile `(and (zerop (sub ,(leftexp scheme-expression)
				    ,(rightexp scheme-expression))))))
	((quotep scheme-expression)
	 lambda-nil)
	((cons-p scheme-expression)
	 `((,lambda-cons ,(compile (leftexp scheme-expression)))
	   ,(compile (rightexp scheme-expression))))
	((carp scheme-expression)
	 `(,lambda-car ,(compile (car-exp scheme-expression))))
	((cdrp scheme-expression)
	 `(,lambda-cdr ,(compile (cdr-exp scheme-expression))))
	((nullp scheme-expression)
	 `(,lambda-null ,(compile (null-exp scheme-expression))))
	((lambdap scheme-expression)
	 (if (lambda-no-parametersp scheme-expression)
	     `(lambda () ,(compile (lambda-exp scheme-expression)))
	   `(lambda (,(lambda-parameter scheme-expression))
	      ,(compile (lambda-exp scheme-expression)))))
	((letp scheme-expression)
	 (compile `((lambda (,@(let-variable scheme-expression))
		      ,(let-body scheme-expression))
		    ,@(let-expression scheme-expression))))
	((letrecp scheme-expression)
	 (compile `(let ((,(letrec-variable scheme-expression)
			  (,Y (lambda (,(letrec-variable scheme-expression))
				,(letrec-expression scheme-expression)))))
		     ,(letrec-body scheme-expression))))
	((applicationp scheme-expression)
	 (if (= (length scheme-expression 1))
	     (compile `(,(compile f) ,lambda-void))
	   `(,(compile (leftexp scheme-expression))
	     ,(compile (rightexp scheme-expression))))
	(t
	 "hello"))))

; Void.
(defvar lambda-void `(λ (void) void))

; Error.
(defvar lambda-error '(λ (_) 
                 ((λ (f) (f f)) (λ (f) (f f)))))

; Booleans.
(defvar lambda-true  `(λ (t) (λ (f) (t ,VOID))))
(defvar lambda-false `(λ (t) (λ (f) (f ,VOID))))

; Church numerals.
(defun church-numeral (n)
  
  (defun apply-n (f n z)
    (cond
      ((= n 0)  z)
      (t     `(,f ,(apply-n f (- n 1) z))]))
       
  (cond
    ((= n 0)    `(λ (f) (λ (z) z))]
    (t      `(λ (f) (λ (z) 
                          ,(apply-n 'f n 'z)))]))

(defvar lambda-zero? `(λ (n)
                 ((n (λ (_) ,FALSE)) ,TRUE)))
                  
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
                 ((m ,PRED) n))))


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
                ,lambda-erros)))

"(defvar PAIR? `(λ (list)
                 ((list (λ (_) (λ (_) ,TRUE)))
                  (λ (_) ,FALSE))))"

(defvar lambda-nullp `(λ (list)
                 ((list (λ (_) (λ (_) ,FALSE)))
                  (λ (_) ,TRUE))))


; Recursion.
(defvar Y '((λ (y) (λ (F) (F (λ (x) (((y y) F) x))))) 
            (λ (y) (λ (F) (F (λ (x) (((y y) F) x)))))))


(defun integerp (exp)
  "Checks if EXP is an integer."
  (and (not (listp exp))
       (numberp exp)))

(defun zerop (exp)
  "checks if EXP is a zero."
  (and (numberp exp)
       (equalp exp 0)))

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
       (equalp (car exp) 'equalp)))

(defun quotep (exp)
  "Checks if EXP is a quote."
  (and (listp exp)
       (equalp (car exp) 'quote)))

(defun consp (exp)
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
  (car (cdr (car (car (cdr h))))))

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
  (car (cdr (car (car (cdr h))))))

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

(defun lambda-parameter (lambda-exp)
  "gets the lambda paramater."
  (car (car (cdr exp))))

(defun lambda-exp (exp)
  "gets the lambda expression."
  (car (cdr (cdr exp))))
