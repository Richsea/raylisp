(in-package :raylisp)

(deftype color ()
  `vec)

(deftype point ()
  'vec)

(deftype interpolated-pattern-function ()
  `(function (point) (values (single-float 0.0 1.0) &optional)))

(deftype indexed-pattern-function ()
  `(function (point) (values array-index &optional)))

(deftype pigment-function ()
  `(function (color point) (values color &optional)))

(deftype shader-function ()
  `(function (color point vec single-float ray counter-vector)
             (values color &optional)))

(deftype perturbation-function ()
  `(function (vec vec point) (values vec &optional)))

(deftype background-shader-function ()
  `(function (color ray) (values color &optional)))

(defconstant +pi+ (coerce pi 'single-float))

(deftype float (&optional (min '*) (max '*))
  `(single-float ,min ,max))

(declaim (inline float))
(defun float (x)
  (coerce x 'single-float))

(declaim (inline floatp))
(defun floatp (x)
  (typep x 'single-float))

(defun negative-infinity-vec ()
  (let ((inf sb-ext:single-float-negative-infinity))
    (vec inf inf inf)))

(defun positive-infinity-vec ()
  (let ((inf sb-ext:single-float-positive-infinity))
    (vec inf inf inf)))

;;; Damned inconvenient that SBCL insists on using (SIGNED-BYTE 32) for these!
(declaim (inline pack-single unpack-single))
(defun pack-single (single)
  (declare (single-float single))
  (logand #xffffffff (sb-kernel:single-float-bits single)))
(defun unpack-single (word)
  (declare (type (unsigned-byte 32) word))
  (sb-kernel:make-single-float
   (logior (- (logand #x80000000 word)) word)))

;;;# Utilities
;;;
;;; Note: RAYLISP shadows VECTOR and SIMPLE-VECTOR; we set up things
;;; to that SIMPLE-VECTOR function works as CL:VECTOR, and represents
;;; the same type and class as CL:SIMPLE-VECTOR.

(deftype simple-vector (&optional size)
  "Alias for CL:VECTOR type."
  `(cl:simple-vector ,size))

(defun simple-vector (&rest args)
  "Alias for CL:VECTOR function."
  (apply #'cl:vector args))

(define-compiler-macro simple-vector (&rest args)
  `(cl:vector ,@args))

(defun float-vector (&rest contents)
  (make-array (length contents) :element-type 'float :initial-contents contents))

(define-compiler-macro float-vector (&rest contents)
  (declare (list contents))
  (if (not contents)
      #.(make-array 0 :element-type 'float)
      (let ((form
             `(make-array ,(length contents) :element-type 'float
                          :initial-contents (list ,@contents))))
        (if (every #'floatp contents)
            `(sb-ext:truly-the
              (simple-array float (,(length contents)))
              (load-time-value ,form t))
            form))))

(defmacro with-arrays (arrays &body body)
  "Provides a corresponding accessor for each array as a local macro,
so that (ARRAY ...) corresponds to (AREF ARRAY ...)."
  `(macrolet ,(mapcar (lambda (array)
			`(,array (&rest indices) `(aref ,',array ,@indices)))
		      arrays)
     ,@body))

;;; Note: our +EPSILON+ is purely experimental.
(defconstant +epsilon+ 0.001
  "Used as a liminal value to work around floating point inaccuracy.")

(declaim (inline significantp))
(defun significantp (x)
  "True if X is greater then +EPSILON+."
  (declare (type float x))
  (< +epsilon+ x))

(defun approximates (x y)
  "An loose equality. Two floats approximate each other if they are within
+EPSILON+ of each other. Two sequences approximate each other if all their
elements are approximate each other. Everything else is an approximate only if
they are EQUAL."
  (cond ((and (floatp x) (floatp y))
         (>= +epsilon+ (abs (- x y))))
        ((and (typep x 'sequence) (typep y 'sequence))
          (every #'approximates x y))
        (t
         (equal x y))))

(declaim (inline =~))
(defun =~ (x y)
  (declare (single-float x y))
  (<= (- +epsilon+) (- x y) +epsilon+))

(defmacro let-values (bindings &body forms)
  "MULTIPLE-VALUE-BIND equivalent for multiple bindings."
  (labels ((rec (binds)
	     (if binds
		 (destructuring-bind ((vars values-form) &rest tail) binds
		   `((multiple-value-bind ,vars ,values-form
		       ,@(rec tail))))
		 forms)))
    (first (rec bindings))))

(defmacro let-plists (bindings &body forms)
  "DESTRUCTURING-BIND &KEY utility."
  (let (all-vars)
    (labels ((rec (binds)
               (if binds
                   (destructuring-bind ((vars plist-form) &rest tail) binds
                     (let ((wrapped (mapcar (lambda (var)
                                              (cond ((consp var)
                                                     (push (second var) all-vars)
                                                     (list var))
                                                    (t
                                                     (push var all-vars)
                                                     var)))
                                            vars)))
                       `((destructuring-bind (&key ,@wrapped) ,plist-form
                           ,@(rec tail)))))
                   `((let ,(mapcar (lambda (var) `(,var ,var)) all-vars)
                       ,@forms)))))
      (first (rec bindings)))))

(defmacro definterface (name keywords target)
  "Interace macro generator for BOA functions: specify a list of keywords and
defaults in order. Macro expands to a call to target with the arguments in
specified order while preserving the order of evaluation apparent at the call
site."
  (let ((keys (mapcar (lambda (spec)
                        (intern (string (if (consp spec) (car spec) spec))
                                :keyword))
                      keywords))
        (defaults (mapcar (lambda (spec)
                            (if (consp spec)
                                (second spec)
                                `(required-argument
                                  ,(intern (string spec) :keyword))))
                          keywords)))
    `(defmacro ,name (&rest args &key ,@keywords)
       (declare (ignore ,@(mapcar (lambda (spec)
                                    (if (consp spec) (car spec) spec))
                                  keywords)))
       (let ((alist nil))
         (do ((key (pop args) (pop args))
              (value (pop args) (pop args)))
             ((not key))
           (push (list key (gensym (string key)) value) alist))
         `(let ,(mapcar (lambda (elt)
                          (list (second elt) (third elt)))
                        (reverse alist))
            (,',target ,@(mapcar (lambda (key default)
                                (let ((cell (assoc key alist)))
                                  (if cell
                                      (second cell)
                                      default)))
                              ',keys
                              ',defaults)))))))

;;;; Our protocols trust function types, so we want to make
;;;; sure generated functions actually have the right type!
(defun check-function-type (function type-name)
  (unless (functionp function)
    (error "~S is not a ~S" function type-name))
  ;; So it's a function. Now check the exact type.
  (let* ((target-ctype (sb-kernel:specifier-type type-name))
         (real-type (sb-impl::%fun-type function))
         (real-ctype (sb-kernel:specifier-type real-type)))
    ;; First check for the exact type.
    (unless (sb-kernel:csubtypep real-ctype target-ctype)
      ;; Then check for the opposite: if this is true, the compiler
      ;; is possibly just missing type information.
      (let ((target-type (sb-kernel:type-specifier target-ctype)))
        (if (sb-kernel:csubtypep target-ctype real-ctype)
            (cerror "Ignore the issue and hope for the best."
                    "~@<~S is a function of type ~S, but a ~S must be of type ~S ~
                     is wanted. The function in question may actually have fully compatible ~
                     behaviour, in which case adding type information to its definition ~
                     will take care of the issue.~:@>"
                    function real-type type-name target-type)
            (error "~@<~S is a function of type ~S, but a ~S must be of type ~S.~:@>"
                   function real-type type-name target-type)))))
  function)

(defmacro define-named-lambda (name result-type typed-lambda-list &key (safe t))
  (with-gensyms (whole)
    (let ((lambda-name (make-symbol "NAME")))
      `(defmacro ,name (&whole ,whole ,lambda-name ,(mapcar #'car typed-lambda-list) &body body)
         (expand-named-lambda ',result-type ',(mapcar #'second typed-lambda-list)
                              ,lambda-name
                              (list ,@(mapcar #'car typed-lambda-list))
                              body
                              ,whole
                              ,safe)))))

(defun expand-named-lambda (result-type arg-types name lambda-vars body whole safe)
  (multiple-value-bind (forms declarations doc)
      (parse-body body :documentation t :whole whole)
    `(sb-int:named-lambda ,name (,@lambda-vars)
       ,@(when doc (list doc))
       (declare ,@(mapcar (lambda (type arg) `(type ,type ,arg))
                          arg-types
                          lambda-vars)
                (optimize (sb-c::recognize-self-calls 0)
                          (sb-c::type-check ,(if safe 1 0))
                          (sb-c::verify-arg-count ,(if safe 1 0))))
       (the ,result-type
         (values
          (block ,name
            (locally
                (declare (optimize (sb-c::type-check 1) (sb-c::verify-arg-count 1)))
              (let ,(mapcar #'list lambda-vars lambda-vars)
                ,@declarations
                ,@forms))))))))
