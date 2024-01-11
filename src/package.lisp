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
	   #:parse-with-lexer
	   #:token-generator
	   #:lex-line
	   #:*python-grammar*
	   #:clean

	   #:make-instruction
	   #:make-atomic-var
	   #:make-immediate
	   #:make-callq
	   #:make-py-module
	   #:make-py-sum
	   #:make-atomic-sum
	   #:make-py-cmp
	   #:make-py-if
	   #:make-if-atomic
	   #:make-py-neg-num
	   #:make-py-assignment
	   #:make-py-print
	   #:make-py-neg-num
	   #:make-py-constant
	   #:make-py-print
	   #:make-py-var
	   #:make-atomic-assignment
	   #:make-py-constant))

(defpackage #:zetta-var
  (:use))

(defpackage #:lambda-server
  (:use #:common-lisp
	#:scheme-to-lambda-calculus
	#:hunchentoot
	#:cps-compiler
	#:zetta
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
	   #:launch))

