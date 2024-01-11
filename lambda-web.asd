(asdf:defsystem #:lambda-web
  :description "A compiler web explorer."
  :author "Job Hernandez <hj93@protonmail.com>"
  :version (:read-file-form "VERSION.txt")
  :depends-on (#:alexa #:yacc :mito :cl-pass :trivial-hashtable-serialize #:alexandria #:hunchentoot #:trivia #:com.inuoe.jzon)
  :license "MIT License"
  :around-compile (lambda (compile)
		    (let (#+sbcl (sb-ext:*derive-function-types* t))
		      (funcall compile)))
  :serial t
  :pathname "src/"
  :components
  ((:file "package")
   (:file "server")
   (:file "compilation-functions")
   (:file "database")
   (:file "handlers")
   (:module "cpscompiler"
    :components
	    ((:file "parser")
	     (:file "desugar")
	     (:file "cps")))
   (:module "scheme-to-lambda"
    :components
	    ((:file "compiler")))
   (:module "pycompiler"
    :components
	    ((:file "lexer")
	     (:file "ast")
	     (:file "pyparser")
	     (:file "expose-allocation")
	     (:file "remove-complex-operands")
	     (:file "select-instructions")
	     (:file "assign-homes")))
   (:module "lalg-compiler"
    :components
	    ((:file "lexer")
	     (:file "syntax-ast")
	     (:file "parser")
	     (:file "cast")
	     (:file "c-intermediate-language")
	     (:file "compile-to-c")
	     (:file "lispast")
	     (:file "lispIL")
	     (:file "generatelisp")))))


