(in-package #:zetta)

(defstruct py-module
  statements)

(defstruct py-print
  exp)

(defstruct py-function
  name
  args
  statements)

(defstruct py-while
  prestatements
  exp
  body-statements)

(defstruct py-if
  exp
  if-statement
  else-statement)

(defstruct py-neg-num
  num)

(defstruct py-sum
  lexp
  rexp)

(defstruct py-sub
  lexp
  rexp)

(defstruct py-bool
  bool)

(defstruct py-bool-op
  lexp
  op
  rexp)

(defstruct py-unary
  op
  exp)

(defstruct py-cmp
  lexp
  cmp
  rexp)

(defstruct py-var
  name)

(defstruct py-assignment
  name
  exp)

(defstruct py-constant
  num)

(defstruct tuple
  int)

(defstruct tuple-index tuple index)

(defstruct function-call var exp)
