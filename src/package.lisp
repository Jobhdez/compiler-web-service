(defpackage #:scheme-to-lambda-calculus
  (:use #:common-lisp)
  (:export #:compile-scheme
	   #:repl))

(defpackage #:cps-compiler
	(:use #:common-lisp #:trivia)
	(:export #:parse-exp #:desugar #:cps))

(defpackage #:zetta
  (:use #:common-lisp
	#:alexa
	#:yacc
	#:trivia
	#:alexandria)
  (:export #:select-instructions
	   #:remove-complex-operands
	   #:assign-homes
	   #:*python-grammar*
	   #:lex-line
	   #:token-generator
	   #:clean
	   #:parse-with-lexer))

(defpackage #:zetta-var
  (:use))

(defpackage #:yotta
  (:use #:common-lisp
	#:alexa
	#:yacc
	#:alexandria
	#:trivia)
  (:export #:make-lisp-interlan
	   #:*linear-algebra-grammar*
	   #:make-lisp-interlan
	   #:make-c-interlan
	   #:generate-lisp
	   #:compile-to-c
	   #:token-generator*
	   #:lex-line*)
  (:shadow #:parse-with-lexer))
  
(defpackage #:yotta-var
  (:use))

(defpackage #:lambda-server
  (:use #:common-lisp
	#:scheme-to-lambda-calculus
	#:hunchentoot
	#:cps-compiler
	#:zetta
	#:yotta
	#:com.inuoe.jzon
	#:mito)
  (:export #:start-server
	   #:stop-server
	   #:*server*
	   #:launch
	   #:connect-to-postgres
	   #:ensure-tables
	   #:+format-string+
	   #:open-browser
	   #:launch
	   #:compile-zetta
	   #:compile-yotta))

