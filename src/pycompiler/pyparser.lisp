(in-package #:zetta)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun build-module (statements)
    (make-py-module :statements (flatten statements)))

  (defun build-print (print-token left-paren-token exp right-paren-token)
    (declare (ignore print-token left-paren-token right-paren-token))
    (make-py-print :exp exp))

  (defun build-while (pre-statem while-token exp colon-tok statements semicolon-tok)
    (declare (ignore while-token colon-tok semicolon-tok))
    (make-py-while :prestatements pre-statem :exp exp :body-statements statements))

  (defun build-if (if-token exp colon-tok statement else-tok colon2-tok statement2)
    (declare (ignore if-token colon-tok else-to colon2-tok))
    (make-py-if :exp exp :if-statement statement :else-statement statement2))

  (defun build-neg-num (minus-token exp)
    (declare (ignore minus-token))
    (make-py-neg-num :num exp))

  (defun build-addition (exp plus-token exp2)
    (declare (ignore plus-token))
    (make-py-sum :lexp exp :rexp exp2))

  (defun build-sub (exp neg-token exp2)
    (declare (ignore neg-token))
    (make-py-sub :lexp exp :rexp exp2))

  (defun build-bool (bool)
    (make-py-bool :bool bool))

  (defun build-bool-op (exp bool-op exp2)
    (make-py-bool-op :lexp exp :op bool-op :rexp exp2))

  (defun build-unaryop (unaryop exp)
    (make-py-unary :op unaryop :exp exp))

  (defun build-cmp (exp cmp exp2)
    (make-py-cmp :lexp exp :cmp cmp :rexp exp2))

  (defun build-variable (var)
    (make-py-var :name var))

  (defun build-fn-name (fn-name)
    (make-fn-name :name fn-name))

  (defun build-assignment (name assignment-token exp)
    (declare (ignore assignment-token))
    (make-py-assignment :name name :exp exp))

  (defun build-int (num)
    (make-py-constant :num num))

  (defun build-function (fun-tok var lparen-tok args r-paren colon-tok statements semicolontoken)
    (declare (ignore fun-tok lparen-tok r-paren colon-tok semicolontoken))
    (make-py-function :name var
		      :args args
		      :statements statements))

  (defun build-tuple (tuple-tok lparen-tok elements rparen-tok)
    (declare (ignore tuple-tok lparen-tok rparen-tok))
    (make-tuple :int (flatten elements)))

  (defun build-tuple-index (tuple lbracket index rbracket)
    (declare (ignore lbracket rbracket))
    (make-tuple-index :tuple tuple :index index))

  (defun build-function-call (var lparen-tok exp rparen-tok)
    (declare (ignore lparen-tok rparen-tok))
    (make-function-call :var var :exp exp))

  (define-parser *python-grammar*
      (:start-symbol module)
    (:terminals (:boolop :unaryop  :left-bracket :right-bracket :cmp :tuple :bool :assignment :if :else :while :colon :name :constant :comma :right-paren :left-paren :print :plus :minus :def :semicolon))
    (module
     (statements #'build-module))
    (statements
     statement
     exp
     (statement statements)
     (exp statements))
    (statement
     (:print :left-paren :right-paren)
     (:print :left-paren exp :right-paren #'build-print)
     tuple-index
     function
     exp
     assignment
     (statements :while exp :colon statements :semicolon #'build-while)
     (:if exp :colon statements :else :colon statements #'build-if))
    (function
     (:def variable :left-paren args :right-paren :colon statements :semicolon #'build-function))
    (exp
     function-call
     variable
     int
     (:minus exp #'build-neg-num)
     (exp :plus exp #'build-addition)
     (exp :minus exp #'build-sub)
     (:bool #'build-bool)
     (exp :boolop exp #'build-bool-op)
     (:unaryop exp #'build-unaryop)
     (exp :cmp exp #'build-cmp)
     tuple)
    (function-call
     (variable :left-paren exp :right-paren #'build-function-call))
    (tuple
     (:tuple :left-paren elements :right-paren #'build-tuple))
    (elements
     int
     (int elements))
    (tuple-index
     (tuple :left-bracket int :right-bracket #'build-tuple-index))
    (args
     variable
     (variable args))
    (variable
     (:name #'build-variable))
    (function-name variable #'build-fn-name)
    (assignment
     (:name :assignment exp #'build-assignment))
    (int
     (:constant #'build-int))))


