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
	   #:zetta-parse-with-lexer
	   #:zetta-token-generator
	   #:zetta-lex-line
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

(defpackage #:yotta
  (:use #:common-lisp
	#:alexa
	#:yacc
	#:alexandria
	#:trivia)
  (:export #:yotta-token-generator
	   #:make-lisp-interlan
	   #:yotta-lex-line
	   #:*linear-algebra-grammar*
	   #:yotta-parse-with-lexer
	   #:program
	   #:make-program
	   #:plus
	   #:make-plus
	   #:minus
	   #:make-minus
	   #:mul
	   #:make-mul
	   #:vec
	   #:make-vec
	   #:matrix
	   #:make-matrix
	   #:num
	   #:make-num
	   #:var
	   #:make-var
	   #:assignment
	   #:make-assignment
	   #:defvarlisp
	   #:make-defvarlisp
	   #:vectorlisp
	   #:make-vectorlisp
	   #:matrixlisp
	   #:make-matrixlisp
	   #:numlisp
	   #:make-numlisp
	   #:looplisp
	   #:make-looplisp
	   #:vectorsum
	   #:make-vectorsum
	   #:vectorminus
	   #:make-vectorminus
	   #:matrixsum
	   #:make-matrixsum
	   #:matrixminus
	   #:make-matrixminus
	   #:setflisp
	   #:make-setflisp
	   #:setqlisp
	   #:make-setqlisp
	   #:areflisp
	   #:make-areflisp
	   #:sumlisp
	   #:make-sumlisp
	   #:minuslisp
	   #:make-minuslisp
	   #:prognlisp
	   #:make-prognlisp
	   #:letexpressionlisp
	   #:make-letexpression
	   #:dotproduct
	   #:make-dotproduct
	   #:fakevecmul
	   #:make-fakevecmul
	   #:matrixmul
	   #:make-matrixmul
	   #:incflisp
	   #:make-incflisp
	   #:mullisp
	   #:make-mullisp))

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
	   #:launch))

