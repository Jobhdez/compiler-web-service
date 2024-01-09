(in-package #:zetta)

(defstruct immediate
  int)

(defstruct register
  reg)

(defstruct deref
  "Memory reference"
  reg
  int)

(defstruct instruction
  name
  arg1
  arg2)

(defstruct callq
  label)

(defstruct block-py name)

(defstruct free-pointer register)

(defstruct from-space register)

(defstruct tag t)

(defun select-instructions (ast)
  (let ((blocks (make-hash-table :test 'equalp)))
    (labels ((select-instrs (node)
	       (match node
		 ((py-assignment :name var-name
				 :exp e1)
		  (cond ((atomic-sum-p e1)
			 (let ((tmp-var (atomic-sum-rexp e1)))
			   (list (make-instruction :name "movq"
						   :arg1 (make-immediate :int (py-constant-num
									       (atomic-sum-lexp e1)))
						   :arg2 var-name)
				 (make-instruction :name "addq"
						   :arg1 tmp-var
						   :arg2 var-name))))
			((allocate-p e1)
			 (list (make-instruction :name "movq"
						 :arg1 (make-free-pointer :register "(%rip)")
						 :arg1 "%r11")
			       (make-instruction :name "addq"
						 :arg1 (concatenate 'string "8" "(" (write-to-string (+ (allocate-len e1) 1)))
						 :arg2 (make-free-pointer :register "%rip"))
			       (make-instruction :name "movq"
						 :arg1 (make-tag :t 'tag)
						 :arg2 "0(%r11)")
			       (make-instruction :name "movq"
						 :arg1 "%r11"
						 :arg2 var-name)))
			
			((py-constant-p  e1)
			 (make-instruction :name "movq"
					   :arg1 e1
					   :arg2 var-name))

			((py-sum-p e1)
			 (let ((tmp-var (py-sum-rexp e1)))
			   (list (make-instruction :name "movq"
						   :arg1 (py-sum-lexp e1)
						   :arg2 var-name)
				 (make-instruction :name "addq"
						   :arg1 (py-sum-rexp e1)
						   :arg2 var-name))))

			((py-sub-p e1)
			 (let ((var (py-sub-lexp e1)))
			   (if (py-var-p var)
			       (if (equalp (py-var-name var)
					   (atomic-var-name var-name))
				   (list (make-instruction :name "subq"
							   :arg1 "$1"
							   :arg2 var-name))))))

			((and (atomic-var-p var-name)
			      (atomic-var-p e1))
			 (make-instruction :name "movq"
					   :arg1 var-name
					   :arg2 e1))



			(t (error "Not valid PY-ASSIGNMENT."))))					 

		 ((atomic-assignment :temp-var tmp
				     :n n)
		  (cond ((atomic-sum-p n)
			 (let ((vari (atomic-sum-lexp n))
			       (rexp (py-constant-num (atomic-sum-rexp n))))
			   (list (make-instruction :name "movq"
						   :arg1 rexp
						   :arg2 tmp)
				 (make-instruction :name "addq"
						   :arg1 vari
						   :arg2 tmp))))
                        ((global-value-p n)
			 (if (equalp (global-value-arg1 n) 'free_ptr)
			     (make-instruction :name "movq"
					       :arg1 (make-free-pointer :register "(%rip)")
					       :arg2 tmp)
			     (make-instruction :name "movq"
					       :arg1 (make-from-space :register "(%rip)")
					       :arg2 tmp)))
			

			((atomic-sum-p n)
			 (list (make-instruction :name "movq"
						 :arg1 (atomic-sum-lexp n)
						 :arg2 tmp)
			       (make-instruction :name "addq"
						 :arg1 (atomic-sum-rexp n)
						 :arg2 tmp)))
			
			
			((py-neg-num-p n)

			 (let* ((num (py-constant-num (py-neg-num-num n)))
				(tmp-var tmp))
					;(setf (gethash "%rax" *registers*) "%rax")
					;(setf (gethash 'py-neg-num *expressions*) 'py-neg-num)
			   (list
			    (make-instruction :name "movq"
					      :arg1 num
					      :arg2 tmp-var)
			    (make-instruction :name "subq"
					      :arg1 tmp-var
					      :arg2 'no-arg))))))
		 ((py-print :exp e1)
		  (if (or (py-var-p e1) (atomic-var-p e1))
		      (list (make-callq :label "print_int"))))


		 ((atomic-sum :lexp e1 :rexp e2)
		  (cond ((py-constant-p e1)
			 (list (make-instruction :name "addq"
						 :arg1 (py-constant-num e1)
						 :arg2 reg)
			       (make-instruction :name "retq"
						 :arg1 'no-arg
						 :arg2 'no-arg)))
			(t (error "E1 isnt a constant."))))

		 ((if-atomic :block b1 :begin-then bthen :begin-else bels :condition e)
		  (let* ((set-instrs1 (mapcar (lambda (instr) (select-instrs instr))
					      (if (listp bthen)
						  bthen
						  (list bthen))))
			 (set-instrs2 (mapcar (lambda (instr) (select-instrs instr))
					      (if (listp bels)
						  bels
						  (listp bels))))
			 (conditional (select-instrs e)))
		    (list conditional
			  (make-instruction :name "je" :arg1 b1 :arg2 'no-arg)
			  (make-instruction :name "jmp" :arg1 "block_2" :arg2 'no-arg)
			  (make-block-py :name b1)
			  set-instrs1
			  (make-block-py :name "block_2")
			  set-instrs2)))

		 ((while-atomic :loop-block loopb :test-block testb :pre-block preb)
		  (let ((setloopb (mapcar (lambda (n) (select-instrs n)) (if (listp loopb) loopb (list loopb))))
			(settestb (mapcar (lambda (n) (select-instrs n)) (if (listp testb) testb (list testb))))
			(setpreb (mapcar (lambda (n) (select-instrs n)) (if (listp preb) preb (list preb)))))
		    (list setpreb
			  (make-instruction :name "jmp" :arg1 "test" :arg2 'no-arg)
			  (make-instruction :name "jg" :arg1 "loop" :arg2 'no-arg)
			  (make-block-py :name "loop:")
			  setloopb
			  (make-block-py :name "test:")
			  settestb)))
		 
		 ((collect :bytes bytes)
		  (list (make-instruction :name "movq"
					  :arg1 "%r15"
					  :arg2 "%rdi")
			(make-instruction :name "movq"
					  :arg1 (concatenate 'string "$" (write-to-string bytes))
					  :arg2 "%rsi")
			(make-callq :label "collect")))

		 ((py-function :name name :args args :statements statements)
		  (cond ((py-sum-p statements)
			 (flatten
			  (list
			   (loop for i in (if (listp args) args (list args))
				 for j in (list "rdi" "rsi" "rdx" "rcx" "r8" "r9")
				 collect (make-instruction :name "movq" :arg1 j :arg2 i))
			   (make-instruction :name "movq"
					     :arg1 (make-atomic-var :name (py-var-name (py-sum-lexp statements)))
					     :arg2 "%rax")
			   (make-instruction :name "addq"
					     :arg1 (make-atomic-var :name (py-var-name (py-sum-rexp statements)))
					     :arg2 "%rax"))))
			((list-of-atomic-assignment-p statements)
			 (flatten (list (loop for i in (if (listp args) args (list args))
					      for j in (list "rdi" "rsi" "rdx" "rcx" "r8" "r9")
					      collect (make-instruction :name "movq" :arg1 j :arg2 i))
					
					(make-from-atomic-assignments statements))))
			(t
			  (flatten (list (loop for i in (if (listp args) args (list args))
					      for j in (list "rdi" "rsi" "rdx" "rcx" "r8" "r9")
					       collect (make-instruction :name "movq" :arg1 j :arg2 i))
					 (select-instructions statements))))))
					 

		 ((function-call :var var :exp exp)
		  (let ((fn-name (generate-fn-name "fun")))
		    
		    (list
		     (make-instruction :name "leaq"
				       :arg1 var
				       :arg2 fn-name)
		     (if (not (listp exp))
			 (loop for i in (list exp)
			       for j in (list "rdi" "rsi" "rdx" "rcx" "r8" "r9")
			       collect (make-instruction :name "movq"
							 :arg1 i
							 :arg2 j))
			 (loop for i in exp
			       for j in (list "rdi" "rsi" "rdx" "rcx" "r8" "r9")
			       collect (make-instruction :name "movq"
							 :arg1 i
							 :arg2 j)))
		     (make-callq :label fn-name)
		     (make-instruction :name "movq"
				       :arg1 "%rax"
				       :arg2 "temp1")
		     (make-instruction :name "movq"
				       :arg1 "temp1"
				       :arg2 "%rdi")
		     (make-callq :label "print_int"))))
		 
		 ((py-cmp :lexp e1 :cmp compare :rexp e2)
		  (cond ((equalp "==" (string-upcase compare))
			 (list (make-instruction :name "movq"
						 :arg1 (make-immediate :int (py-constant-num e1))
						 :arg2 "%rsi")
			       (make-instruction :name "movq"
						 :arg1 (make-immediate :int (py-constant-num e2))
						 :arg2 "%rdi")
			       (make-instruction :name "cmpq"
						 :arg1 "%rsi"
						 :arg2 "%rdi")))
			((equalp ">" (string-upcase compare))
			 (if (equalp 1 (py-constant-num e2))
			     (list (make-instruction :name "cmpq"
						     :arg1 "$1"
						     :arg2 (if (py-var-p e1) (make-atomic-var :name (py-var-name e1)) e1)))))
			((equalp "<" (string-upcase compare))
			 (list (make-instruction :name "cmpq"
						 :arg1 e2
						 :arg2 e1))))))))
      (alexandria::flatten (mapcar (lambda (n) (select-instrs n)) ast)))))



(defun list-of-atomic-assignment-p (statements)
  (cond ((null statements) T)
	((not (atomic-assignment-p (car statements))) nil)
	(t (and (atomic-assignment-p (car statements))
		(list-of-atomic-assignment-p (cdr statements))))))

(defun make-from-atomic-assignments (statements)
  (labels ((make-from (statement)
	     (match statement
	       ((atomic-assignment :temp-var var :n n)
		(cond ((py-neg-num-p n)
		       (list (make-instruction :name "movq" :arg1 (py-neg-num-num n) :arg2 var)
			     (make-instruction :name "subq" :arg1 var :arg2 'no-arg)))
		      ((atomic-sum-p n)
		       (list (make-instruction :name "movq"
					       :arg1 (atomic-sum-rexp n)
					       :arg1 "%rax")
			     (make-instruction :name "addq"
					       :arg1 (atomic-sum-lexp n)
					       :arg2 "%rax")))
		      (t (error "not valid instruction.")))))))
    (mapcar (lambda (statement) (make-from statement)) statements)))


(defvar namecounter 0)		     
(defun generate-fn-name (name)
  (progn
    (setf namecounter (+ namecounter 1))
    (concatenate 'string name (write-to-string namecounter))))



