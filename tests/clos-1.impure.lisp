;;;; miscellaneous side-effectful tests of CLOS

;;;; This software is part of the SBCL system. See the README file for
;;;; more information.
;;;;
;;;; While most of SBCL is derived from the CMU CL system, the test
;;;; files (like this one) were written from scratch after the fork
;;;; from CMU CL.
;;;;
;;;; This software is in the public domain and is provided with
;;;; absolutely no warranty. See the COPYING and CREDITS files for
;;;; more information.

;;; clos.impure.lisp was getting too big and confusing

(load "assertoid.lisp")

(defpackage "CLOS-1"
  (:use "CL" "ASSERTOID" "TEST-UTIL"))

;;; tests that various optimization paths for slot-valuish things
;;; respect class redefinitions.
(defclass foo ()
  ((a :initarg :a)))

(defvar *foo* (make-instance 'foo :a 1))

(defmethod a-of ((x foo))
  (slot-value x 'a))
(defmethod b-of ((x foo))
  (slot-value x 'b))
(defmethod c-of ((x foo))
  (slot-value x 'c))

(let ((fun (compile nil '(lambda (x) (slot-value x 'a)))))
  (dotimes (i 4) ; KLUDGE: get caches warm
    (assert (= 1 (slot-value *foo* 'a)))
    (assert (= 1 (a-of *foo*)))
    (assert (= 1 (funcall fun *foo*)))
    (assert (raises-error? (b-of *foo*)))
    (assert (raises-error? (c-of *foo*)))))

(defclass foo ()
  ((b :initarg :b :initform 3) (a :initarg :a)))

(let ((fun (compile nil '(lambda (x) (slot-value x 'a)))))
  (dotimes (i 4) ; KLUDGE: get caches warm
    (assert (= 1 (slot-value *foo* 'a)))
    (assert (= 1 (a-of *foo*)))
    (assert (= 1 (funcall fun *foo*)))
    (assert (= 3 (b-of *foo*)))
    (assert (raises-error? (c-of *foo*)))))

(defclass foo ()
  ((c :initarg :c :initform t :allocation :class)
   (b :initarg :b :initform 3)
   (a :initarg :a)))

(let ((fun (compile nil '(lambda (x) (slot-value x 'a)))))
  (dotimes (i 4) ; KLUDGE: get caches warm
    (assert (= 1 (slot-value *foo* 'a)))
    (assert (= 1 (a-of *foo*)))
    (assert (= 1 (funcall fun *foo*)))
    (assert (= 3 (b-of *foo*)))
    (assert (eq t (c-of *foo*)))))

(defclass foo ()
  ((a :initarg :a)
   (b :initarg :b :initform 3)
   (c :initarg :c :initform t)))

(let ((fun (compile nil '(lambda (x) (slot-value x 'a)))))
  (dotimes (i 4) ; KLUDGE: get caches warm
    (assert (= 1 (slot-value *foo* 'a)))
    (assert (= 1 (a-of *foo*)))
    (assert (= 1 (funcall fun *foo*)))
    (assert (= 3 (b-of *foo*)))
    (assert (eq t (c-of *foo*)))))

(defclass foo ()
  ((b :initarg :b :initform 3)))

(let ((fun (compile nil '(lambda (x) (slot-value x 'a)))))
  (dotimes (i 4) ; KLUDGE: get caches warm
    (assert (raises-error? (slot-value *foo* 'a)))
    (assert (raises-error? (a-of *foo*)))
    (assert (raises-error? (funcall fun *foo*)))
    (assert (= 3 (b-of *foo*)))
    (assert (raises-error? (c-of *foo*)))))