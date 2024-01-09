(in-package #:zetta)

(defstruct global-value arg1)
(defstruct less-than op)
(defstruct collect bytes)
(defstruct allocate len type)
(defstruct *type* type)
(defstruct begin statements)

(defun expose-alloc (ast)
  (expose-allocation (car (py-module-statements ast))))

(defun expose-allocation (tup)
  (match tup
    ((tuple :int elements)
     (let ((temp-names (mapcar (lambda (element) (make-temp-variable element)) elements)))
       (make-begin :statements (flatten
				(list
				 temp-names
				 
				 (make-py-if :exp (make-py-cmp :lexp (make-py-sum :lexp (make-global-value :arg1 'free_ptr)
										  :rexp (make-py-constant :num (* (length elements) 4)))
							       :cmp  "<"
							       :rexp (make-global-value :arg1 'fromspace_end))
					     :if-statement (make-py-constant :num 0)
					     :else-statement (make-collect :bytes (* (length elements) 4)))
				 (make-py-assignment :name 'v
						     :exp (make-allocate :len (length elements)
									 :type (make-*type* :type 'int)))
				 (mapcar (lambda (e) (make-array-variable e)) (mapcar (lambda (element) (py-assignment-name element)) temp-names)))))))))

(defvar temp -1)
(defun make-temp-variable (element)
  (progn (setf temp (+ temp 1))
	 (make-py-assignment :name (concatenate 'string "temp_" (write-to-string temp))
			     :exp element)))

(defvar array-i -1)
(defun make-array-variable (element)
  (progn (setf array-i (+ array-i 1))
	 (make-py-assignment :name (concatenate 'string "v[" (write-to-string array-i) "]")
			     :exp element)))

(defmacro make-variable (element var str) 
  `(progn (setf ,var (+ ,var 1))
          (make-py-assignment :name (concatenate 'string ,str (write-to-string ,var)) :exp ,element)))



