# scheme-to-lambda-compiler
a scheme to lambda calculus compiler just for fun.

Some scheme expressions compile to the lambda calculus. Some don't 
So there's some bugs. Some expressions compile but not compile to the right lambda calculus expression so theres still work to do.

# using the program
As of now I am not able to use `asdf` to load the system.

To load the system navigate to the `src` directory of the project and after running `sbcl` type:
- `(load "packages.lisp")`
- `(load "compiler.lisp")`
- `(in-package #:scheme-to-lambda-calculus)`
