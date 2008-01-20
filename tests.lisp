(in-package :raylisp)

(define-scene test-0
  (:objects 
   (make-instance 'sphere 
                  :shader
                  (make-instance 'flat :color red))
   (make-instance 'sphere 
                  :location (@ 0 -0.5 0)
                  :transform (scale (@ 3 0.5 0.5))
                  :shader
                  (make-instance 'flat :color blue)))
  (:lights 
   (make-instance 'point-light 
                  :location (@ 10 5 -20)))
  (:default-camera 
      (make-instance 'pinhole
                     :location (@ 0 3 -20)
                     :look-at origin
                     :focal-length 4.0)))

(define-scene test-1
  (:objects 
   (make-instance 'sphere 
                  :shader
                  (make-instance 'solid :color red))
   (make-instance 'sphere 
                  :location (@ 0 -0.5 0)
                  :transform (scale (@ 3 0.5 0.5))
                  :shader
                  (make-instance
                   'gradient
                   :start (make-instance 'solid :color blue)
                   :end (make-instance 'solid :color green)
                   :axis 0
                   :scale 3.0)))
  (:lights
   (make-instance 'point-light 
                  :location (@ 10 5 -20)))
  (:default-camera
      (make-instance 'pinhole
                     :location (@ 0 3 -20)
                     :look-at origin
                     :focal-length 4.0)))

(define-scene test-2
  (:objects 
   (make-instance 'sphere
                  :shader
                  (make-instance
                   'composite
                   :shaders
                   (list
                    (make-instance 'raytrace
                                   :specular 0.1
                                   :transmit 0.9
                                   :ior 1.6)
                    (make-instance 'phong
                                   :specular 0.5
                                   :size 40.0
                                   :diffuse 0.3
                                   :ambient 0.2
                                   :color yellow))))
   (make-instance 'plane
                  :location (@ 0 -1 0)
                  :shader
                  (make-instance 'checker
                                 :odd
                                 (make-instance 'phong :color black)
                                 :even
                                 (make-instance 'phong :color white))))
  (:lights 
   (make-instance 'point-light 
                  :location (@ -30 30 -30)))
  (:background-color blue)
  (:ambient-light white)
  (:adaptive-limit 0.01)
  (:depth-limit 12)
  (:default-camera
      (make-instance 'pinhole
                     :location (@ 0 0.5 -4)
                     :look-at origin
                     :focal-length 3.0)))

(define-scene test-3
    (:objects 
     (make-instance
      'csg
      :type 'intersection
      :objects (list
                (make-instance 'sphere
                               :location (@ -0.5 0 0)
                               :shader
                               (make-instance 'solid :color red))
                (make-instance 'sphere
                               :location (@ 0.5 0 0)
                               :shader
                               (make-instance 'solid
                                              :color blue))
                (make-instance 'sphere
                               :location (@ 0 -0.1 0)
                               :shader
                               (make-instance 'solid
                                              :color green)))))
  (:lights 
   (make-instance 'solar-light :direction y-axis))
  (:background-color black)
  (:ambient-light white)
  (:adaptive-limit 0.01)
  (:depth-limit 5)
  (:default-camera
      (make-instance 'pinhole
                     :location (@ 0 1.5 -10)
                     :look-at origin
                     :focal-length 3.0)))

(define-scene test-4
  (:objects 
   (make-instance 'csg
                  :type 'difference
                  :objects
                  (list
                   (make-instance 'sphere
                                  :shader
                                  (make-instance 'solid
                                                 :color red))
                   (make-instance 'sphere
                                  :location (@ 0 1 0)
                                  :shader
                                  (make-instance 'solid
                                                 :color blue))
                   (make-instance 'sphere
                                  :location (@ 1 0 0)
                                  :shader
                                  (make-instance 'solid
                                                 :color green)))))
  (:lights 
   (make-instance 'solar-light :direction (@ 1 1 0.5)))
  (:background-color black)
  (:ambient-light white)
  (:adaptive-limit 0.01)
  (:depth-limit 5)
  (:default-camera
      (make-instance 'pinhole
                     :location (@ 8 6.5 -2)
                     :look-at origin
                     :focal-length 3.0)))

(define-scene test-5
  (:objects 
   (make-instance 'sphere 
                  :radius 0.3
                  :shader (make-instance 'solid :color white))
   (make-instance 
    'csg
    :type 'intersection
    :objects
    (list
     (make-instance 'plane
                    :normal (@ -0.5 1 0)
                    :shader
                    (make-instance 'solid
                                   :color green))
     (make-instance 'plane
                    :normal (@ 0.5 1 0)
                    :shader
                    (make-instance 'solid
                                   :color red)))
    :transform (translate (@ -1 0 0))))
  (:lights 
   #+nil
   (make-instance 'solar-light :direction y-axis)
   (make-instance 'point-light :location (@ 0 200 0)))
  (:background-color black)
  (:ambient-light white)
  (:adaptive-limit 0.01)
  (:depth-limit 5)
  (:default-camera
      (make-instance 'pinhole
                     :location (@ 0 3 -10)
                     :look-at origin
                     :focal-length 3.0)))

(define-scene test-6
  (:objects 
   (make-instance 'sphere
                  :shader
                  (make-instance
                   'composite
                   :shaders
                   (list
                    (make-instance 'raytrace
                                   :specular 0.1
                                   :transmit 0.9
                                   :ior 1.6)
                    (make-instance 'phong
                                   :specular 0.5
                                   :size 40.0
                                   :diffuse 0.3
                                   :ambient 0.1
                                   :color yellow))))
   (make-instance 
    'plane
    :location (@ 0 -1 0)
    :shader
    (make-instance 'checker
                   :odd
                   (make-instance 'phong :color black)
                   :even
                   (make-instance 'phong :color white
                                         :ambient 0.1))))
  (:lights 
   (make-instance 'spotlight
                  :location (@ -30 30 -30)
                  :direction (@ 30 -30 30)
                  :aperture 0.999))
  (:background-color blue)
  (:ambient-light white)
  (:adaptive-limit 0.01)
  (:depth-limit 12)
  (:default-camera
      (make-instance 'pinhole
                     :location (@ 0 0.5 -4)
                     :look-at origin
                     :focal-length 3.0)))

;;;# Tests
;;;
;;; Raylisp includes both test scenes, and a number of functional
;;; regression tests.

(defvar *passed-test-count* 0)
(defvar *failed-tests* nil)

(defmacro test (name form expect)
  (let ((n-expect (gensym))
	(n-form (gensym)))
    `(let ((,n-form ,form)
	   (,n-expect ,expect))
       (cond ((approximates ,n-form ,n-expect)
	      (incf *passed-test-count*))
	     (t
	      (warn "~A failed.~% Expected: ~S, got ~S." 
		    ',name ,n-expect ,n-form)
	      (pushnew ',name *failed-tests*)))
       ',name)))

(defun run-tests ()
  (let ((*passed-test-count* 0)
	(*failed-tests* nil))

    (test-math)
    (test-ray)
    (test-sphere)
    (test-plane)

    (let* ((failed (length *failed-tests*))
	   (total (+ *passed-test-count* failed)))
      (when *failed-tests*
	(format t "~A failed tests:~%  ~{~A ~}~%" 
		failed
		(reverse *failed-tests*)))
      (format t "~&~A tests of ~A passed. (~A%)~%"
	      *passed-test-count* total 
	      (* 100.0 (/ *passed-test-count* total))))))

(defun test-math ()
  (test math.1
	(transform-vector y-axis (reorient y-axis (@ 1 1 1)))
	(normalize (@ 1 1 1)))
  (test math.2 (vector 1.0 2.0 4.654) (@ 1 2 4.654)))

;;; FIXME: OBSOLETE
#+nil
(defun test-ray ()
  (let* ((from (@ 1 0 -1))
	 (direction (normalize (@ -1 0 1)))
	 (ray (make-ray :origin from :direction direction)))
    (multiple-value-bind (reflected refracted)
	(spawn-rays (make-intersection :point origin 
				       :normal (@ 0 0 -1)
				       :n.d (dot-product (@ 0 0 -1) direction))
		    ray
		    0.2
		    0.7
		    1.8)
      (test ray.1.1
	    (ray-direction reflected)
	    (normalize (@ -1 0 -1)))
      (test ray.1.2
	    (ray-direction refracted)
	    (@ -0.3928 0 0.9196))
      (multiple-value-bind (reflected refracted)
	  (spawn-rays (make-intersection :point (ray-direction refracted)
					 :normal (@ 0 0 -1)
					 :n.d (dot-product (@ 0 0 1) (ray-direction refracted)))
		      refracted
		      0.2
		      0.7
		      1.8)
        (declare (ignore reflected))
	(test ray.2
	      (ray-direction refracted)
	      direction)))))

(defun test-sphere ()
  (flet ((make-sphere (radius location &key transform)
	   (compile-object (make-instance 'sphere 
					  :radius radius
					  :location location
					  :transform transform)
			   (make-scene)))
	 (normal (object point)
	   (funcall (object-normal object) point))
	 (intersect (x from dir)
	   (let ((ray (make-ray :origin from :direction dir)))
	     (if (intersect x ray)
		 (ray-extent ray)
		 -1.0))))
    (let ((s (make-sphere 1.0 origin)))
      (test sphere.1.1 (intersect s (@ 0 0 -2) z-axis)
	    1.0)
      (test sphere.1.2 (intersect s (@ 1 0 -2) z-axis)
	    2.0)
      (test sphere.1.3 (intersect s (@ 1 0.001 -2) z-axis)
	    -1.0)
      (test sphere.1.4 
            (let* ((o (@ 0 0 -2))
		   (d (intersect s o z-axis)))
	      (normal s (vector-add o (vector-mul z-axis d))))
	    (@ 0 0 -1)))
    (let ((s (make-sphere 0.5 origin)))
      (test sphere.2.1 (intersect s (@ 0 0 -2) z-axis)
	    1.5)
      (test sphere.2.2 (intersect s (@ 0 0 -1) z-axis)
	    0.5)
      (test sphere.2.3 
	    (let* ((o (@ 0 0 -2))
		   (d (intersect s o z-axis)))
	      (normal s (vector-add o (vector-mul z-axis d))))
	    (@ 0 0 -1)))
    (let ((s (make-sphere 1.0 (@ 1 0 0))))
      (test sphere.3.1 (intersect s (@ -0.001 0 0) z-axis)
	    -1.0))
    
    (let* ((s (make-sphere 1.0 (@ 0 -1 0)))
	   (o (@ 0 -1 -2))
	   (dist (intersect s o z-axis))
	   (pos (vector-add o (vector-mul z-axis dist))))
      (test sphere.4.1 dist 1.0)
      (test sphere.4.2 pos (@ 0 -1 -1))
      (test sphere.4.3 (normal s pos) (@ 0 0 -1)))
    
    (let ((s (make-sphere 1.0 (@ 0 1 0) 
			  :transform (scale (@ 2 1 1))))
	  (x-neg (@ -3 1 0))
	  (y-neg (@ 0 -1 0)))
      (test sphere.5.1 (intersect s x-neg x-axis) 1.0)
      (test sphere.5.2 (intersect s y-neg y-axis) 1.0))))

(defun test-plane ()
  (flet ((make-plane (n v)
	   (compile-object (make-instance 'plane :normal n :location v)
			   (make-scene)))
	 (normal (x v)
	   (funcall (object-normal x) v))
	 (intersect (x from dir)
	   (let ((ray (make-ray :origin from :direction dir)))
	     (if (intersect x ray)
		 (ray-extent ray)
		 -1.0))))
    (let ((p (make-plane y-axis origin)))
      (test plane.1.1 
	    (intersect p (@ 0 1 0) (@ 0 -1 0))
	    1.0))
    (let ((p (make-plane (@ 1 1 0) origin)))
      (test plane.2.1
	    (intersect p (@ 0 1 0) (@ -1 0 0))
	    1.0)
      (test plane.2.2
	    (plusp (intersect p (@ 0 1 0) (@ -1 0.1 0)))
	    t)
      (let ((o (@ 0 1 0))
	    (d (@ -1 0.1 0)))
	(test plane.2.3
	      (normal p (adjust-vector o d (intersect p o d)))
	      (normalize (@ 1 1 0)))))
    (let ((p (make-plane (@ 1 1 0) (@ -1 0 0))))
      (test plane.3.1
	    (intersect p origin (@ 0 -1 0))
	    1.0))))


