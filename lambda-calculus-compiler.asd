(asdf:defsystem #:lambda-calculus-compiler
		:description "A lambda calculus compiler just for fun."
		:author "Job Hernandez <hj93@protonmail.com>"
		:version (:read-file-form "VERSION.txt")
		:license "MIT License"
		:serial t
		:pathname "src/"
		:components
		((:file "compiler")))
