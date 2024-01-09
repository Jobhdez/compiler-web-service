(in-package #:zetta)

(defstruct atomic-assignment
  temp-var
  n)

(defstruct atomic-sum
  lexp
  rexp)

(defstruct atomic-var
  name)

(defstruct if-atomic
  block
  begin-then
  begin-else
  condition)

(defstruct while-atomic
  loop-block
  test-block
  pre-block)

(defun remove-complex-operands (parse-tree)
  "Removes complex operands. Eg each subexpression of a binary-op needs to be
   a atomic expression which is an integer or variable. complex operations
  get assigned to a variable; an example of a complex expression is -10."

  (let ((*temp-names* (make-hash-table))
	(gensym-count 0))
    (labels ((remove-complex (parse-node)
	       
	       (match parse-node
		 ((py-constant :num n)
		  (make-py-constant :num n))

		 ((global-value :arg1 a1)
		  (let ((temp-name (generate-temp-name "temp_")))
		    (make-atomic-assignment :temp-var temp-name
					    :n (make-global-value :arg1 a1))))

		 ((py-function :name f :args args :statements statements)
		  (make-py-function :name f
				    :args args
				    :statements (flatten (mapcar (lambda (instr) (remove-complex instr)) (if (listp statements) statements (list statements))))))
		 
		 ((function-call :var v :exp e)
		  parse-node)

		 ((collect :bytes bytes)
		  (collect :bytes bytes))
		 
		 ((py-neg-num :num n)
		  (make-atomic-assignment :temp-var (make-atomic-var :name (generate-temp-name "temp_"))
					  :n (make-py-neg-num :num n)))
		 
		 ((py-sum :lexp e1 :rexp e2)
		  (cond ((and (py-constant-p e1) (py-constant-p e2))
			 (list (make-py-sum :lexp e1 :rexp e2)))

			((and (py-var-p e1) (py-neg-num-p e2))
			 (let ((temp-1 (generate-temp-name "temp_"))
			       (temp-2 (generate-temp-name "temp_")))
			   (list (make-atomic-assignment :temp-var temp-1
							 :n e2)
				 (make-atomic-assignment :temp-var temp-2
							 :n (make-atomic-sum :lexp (make-atomic-var :name (py-var-name e1))
									     :rexp  temp-1)))))

			
			((or (py-neg-num-p e2) (py-neg-num-p e1))
			 (cond ((py-neg-num-p e2)
				(let* ((rmv-complex (remove-complex e2))
			               (tmp-var (atomic-assignment-temp-var rmv-complex)))
				  (list rmv-complex
					(make-atomic-sum :lexp (remove-complex e1)
							 :rexp tmp-var))))
		               ((py-neg-num-p e1)
				(let* ((rmv-complex (remove-complex e1))
		                       (tmp-var (atomic-assignment-temp-var rmv-complex)))
				  (list rmv-complex
					(make-atomic-sum :lexp tmp-var
							 :rexp (remove-complex e2)))))))
			((and (global-value-p e1) (py-constant-p e2))
			 (let* ((temp-name (generate-temp-name "temp*_"))
				(temp-name2 (generate-temp-name "temp*_")))
			   (list (make-atomic-assignment  :temp-var temp-name
							  :n e1)
			         (make-atomic-assignment :temp-var temp-name2
							 :n (make-atomic-sum :lexp temp-name
									     :rexp e2)))))))

		 ((begin :statements statements)
		  (mapcar (lambda (instr) (remove-complex instr)) statements))
		 
		 
		 ((py-assignment :name name
				 :exp e)
		  (cond ((py-constant-p e)
			 (make-py-assignment :name (make-atomic-var :name name)
					     :exp e))
			((py-sub-p e)
			 (make-py-assignment :name (make-atomic-var :name name)
					     :exp e))
			((and (symbolp name) (py-constant-p e))
			 (make-py-assignment :name (make-atomic-var :name name)
					     :exp e))
			

			((and (stringp name) (stringp e))
			 (make-py-assignment :name (make-atomic-var :name name)
					     :exp (make-atomic-var :name e)))

			

			((allocate-p e)
			 (make-py-assignment :name (make-atomic-var :name name)
					     :exp e))
			
			((py-sum-p e)
			 (cond ((positive-sum-p e)
				e)

			       ((and (py-var-p (py-sum-lexp e))
				     (py-constant-p (py-sum-rexp e)))
				(make-atomic-sum :lexp (py-var-name (py-sum-lexp e))
						 :rexp (py-constant-num (py-sum-rexp e))))
			       
			       ((variable-sum-p e)
				(make-py-assignment :name (make-atomic-var :name name) :exp e))
			       
			       ((negative-sum-p e)
				(let* ((temp-exp (get-temp-var e))
				       (atomic (get-atomic e))
				       (atomic-exp1 (make-py-assignment :name (make-atomic-var :name name)
									:exp (make-atomic-sum :lexp atomic
											      :rexp
											      (atomic-assignment-temp-var
											       temp-exp))))
				       (temp-name (generate-temp-name "temp_")))
				  (setf (gethash name *temp-names*) name)
				  (list temp-exp atomic-exp1)))

		       	       ((symbolp name) 
				(make-py-assignment :name (make-atomic-var :name name)
				                    :exp e))


			       
			       (t (error "No more valid sum expressions."))))

			((py-constant-p e)
			 e)))
		 
		 ((py-print :exp e)
		  (cond ((py-var-p e)
			 (let ((e* (make-py-var :name (make-atomic-var :name (py-var-name e)))))
			   (make-py-print :exp e*)))
			
			((var-num-sum-p e)
			 (let* ((temp-name (generate-temp-name "temp_"))
				(var-name (py-sum-lexp e))
				(num (py-sum-rexp e)))
			   (list (make-atomic-assignment :temp-var (make-atomic-var :name temp-name)
							 :n (make-atomic-sum :lexp (make-atomic-var :name var-name)
									     :rexp num))
				 (make-py-print :exp (make-atomic-var :name temp-name)))))

			(t (error "No other print expressions."))))
		 ((py-if :exp e :if-statement ifs :else-statement els)
		  (cond ((and (py-cmp-p e) (collect-p els))
			 (let ((rmv-py-cmp (remove-complex e)))
			   (list (first rmv-py-cmp)
				 (second rmv-py-cmp)
				 (third rmv-py-cmp)
				 (make-if-atomic :block "block_1"
						 :begin-then ifs
						 :begin-else els
						 :condition (fourth rmv-py-cmp)))))
			(t
			 (make-if-atomic :block "block_1"
					 :begin-then (flatten (mapcar (lambda (instr) (remove-complex instr)) ifs))
					 :begin-else (flatten (mapcar (lambda (instr) (remove-complex instr)) els))
					 :condition e))))

		 ((py-while :prestatements pres
			    :exp e1
			    :body-statements body)
		  (make-while-atomic :loop-block (mapcar (lambda (n) (remove-complex n)) (if (listp body) body (list body)))
				     :test-block e1
				     :pre-block (mapcar (lambda (n) (remove-complex n))
							(if (listp pres)
							    pres
							    (list pres)))))

		 ((py-cmp :lexp lexp :cmp cmp :rexp rexp)
		  (cond ((and (py-sum-p lexp)
			      (global-value-p rexp))
			 (let* ((exps (remove-complex lexp))
				(exps2 (remove-complex rexp))
				(assign1 (car exps))
				(assign2 (car (cdr exps)))
				(temp1 (atomic-assignment-temp-var assign1))
				(temp2 (atomic-assignment-temp-var assign2))
				(temp3 (atomic-assignment-temp-var exps2)))
			   (list
			    assign1
			    assign2
			    exps2
			    (make-py-cmp :lexp temp2 :cmp cmp :rexp temp3))))
			(t parse-node)))
		 (_ (error "no valid expression."))))
	     (generate-temp-name (prefix-name)
	       (progn (setf gensym-count (+ gensym-count 1))
		      (concatenate 'string
				   prefix-name
				   (write-to-string gensym-count)))))
      
      
      
      
      (cond ((py-module-p parse-tree)
	     (if (listp (py-module-statements parse-tree))
		 (flatten (mapcar (lambda (node) (remove-complex node)) (flatten (py-module-statements parse-tree))))))
	    ((begin-p parse-tree)
	     (remove-complex parse-tree))))))


(defun positive-sum-p (node)
  "Checks whether NODE is a sum expression composed of positive numbers."
  (match node
    ((py-sum :lexp e1 :rexp e2)
     (if (and (py-constant-p e1)
	      (py-constant-p e2))
	 t
	 nil))))

(defun variable-sum-p (node)
  "Checks whether NODE is a sum expression composed of variables. eg y + z"
  (match node
    ((py-sum :lexp e :rexp e2)
     (if (and (py-var-p e)
	      (py-var-p e2))
	 t
	 nil))))

(defun negative-sum-p (node)
  "checks if NODE is a sum expression composed of a positive and negative number. eg 10 + -3"
  (match node
    ((py-sum :lexp e :rexp e2)
     (if (and (py-constant-p e)
	      (py-neg-num-p e2))
	 t
	 nil))))

(defun var-num-sum-p (node)
  "checks if node is a sum expression composed of a constant and variable. eg x + 10"
  (match node
    ((py-sum :lexp e :rexp e2)
     (if (and (py-var-p e)
	      (py-constant-p e2))
	 t
	 nil))))

(defvar gensym-count 0)

(defun generate-temp-name (prefix-name)
  (progn (setf gensym-count (+ gensym-count 1))
	 (concatenate 'string
		      prefix-name
		      (write-to-string gensym-count))))

(defun get-temp-var (exp-node)
  (match exp-node
    ((py-sum :lexp e :rexp e2)
     (when (or (py-neg-num-p e)
	       (py-neg-num-p e2))
       (if (py-neg-num-p e)
	   (make-atomic-assignment :temp-var (make-atomic-var :name (generate-temp-name "temp_"))
				   :n e)
	   (make-atomic-assignment :temp-var (make-atomic-var :name (generate-temp-name "temp_"))
				   :n e2))))))

(defun get-atomic (exp-node)
  (match exp-node
    ((py-sum :lexp e :rexp e2)
     (when (or (py-constant-p e)
	       (py-constant-p e2))
       (if (py-constant-p e)
	   e
	   e2)))))


