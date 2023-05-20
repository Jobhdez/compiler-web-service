(asdf:defsystem #:lambda-calculus-compiler
		:description "A lambda calculus compiler just for fun."
		:author "Job Hernandez <hj93@protonmail.com>"
		:version (:read-file-form "VERSION.txt")
		:depends-on (#:hunchentoot #:com.inuoe.jzon #:trivia)
		:license "MIT License"
		:around-compile (lambda (compile)
				  (let (#+sbcl (sb-ext:*derive-function-types* t))
				    (funcall compile)))
		:serial t
		:pathname "src/"
		:components
		((:file "packages")
		 (:file "compiler")
		 (:file "server")
		 (:file "parser")
		 (:file "desugar")
		 (:file "cps")))
