(defpackage cl-synacor
  (:local-nicknames (:a :alexandria)
                    (:b :lisp-binary))
  (:use :cl))
(in-package :cl-synacor)

(defun rel-path (path)
  (asdf:system-relative-pathname
    :cl-synacor path))

(defclass <registry> ()
  ((a :initarg :a
     :accessor a)
    (b :initarg :b
      :accessor b)
    (c :initarg :c
      :accessor c)
    (d :initarg :d
      :accessor d)
    (e :initarg :e
      :accessor e)
    (f :initarg :f
      :accessor f)
    (g :initarg :g
      :accessor g)
    (h :initarg :h
      :accessor h))
  (:default-initargs
    :a 0 :b 0 :c 0 :d 0 :e 0 :f 0 :g 0 :h 0))

(defgeneric print-registry (registry))
(defgeneric get-register-value (num registry))
(defgeneric get-register (num registry))

(defmethod print-registry ((registry <registry>))
  (format t "~{~{~A: ~a~}~^, ~}"
    (loop :for reg :in '(a b c d e f g h)
      :collect (list reg (slot-value *registry* reg)))))

(defmethod get-register-value (num (registry <registry>))
  (slot-value registry (get-register num)))

(defmethod get-register (num (registry <registry>))
  (case num
    (32768 'a)
    (32769 'b)
    (32770 'c)
    (32771 'd)
    (32772 'e)
    (32773 'f)
    (32774 'g)
    (32775 'h)
    (otherwise (error "Invalid Registry! ~a" num))))

(defun setf-register (num new-val &optional (registry *registry*))
  (setf (slot-value registry (get-register num registry)) new-val))

;;-------------------------------------------------------

(defun read-little-endian (in)
  (let ((num 0))
    (setf (ldb (byte 8 0) num) (read-byte in))
    (setf (ldb (byte 8 8) num) (read-byte in))
    num))

(defun parse-bin ()
  (with-open-file (in *bin-file*
                    :element-type '(unsigned-byte 8)
                    :if-does-not-exist :error)
    (setf *program*
      (loop :for i :from 0 :to (1- (/ (file-length in) 2))
        :collect (read-little-endian in)))))


(defparameter *bin-file* (rel-path "src/challenge.bin"))
(defparameter *program* (parse-bin))
(defparameter *registry* (make-instance '<registry>))
(defparameter *instruction* 0)
(defparameter *stack* '())

(defmacro pelt (num &optional (program 'program) (delta 1))
  (prog1 `(elt ,program ,(+ *instruction* num))
    (incf *instruction* delta)))

;; (defmacro arg (num &optional (delta 1))
;;   (incf *instruction* delta)
;;   `(pelt ,num))

;; (defun jmp (instruction)
;;   )

(defun run-program (&optional (program *program*))
  (loop ;:for num :in program :do
        ;;:for i :from 0 :to (length program)
        :for num = (elt program *instruction*)
        :until (> *instruction* (length program)) :do
    (format t "~a, " num)
    (case num
      ;; HALT
      (0 (return-from run-program 'HALT))
      ;; SET
      (1 (setf-register (pelt 1) (pelt 2)))
      ;; PUSH
      (2 (push (pelt 1) *stack*))
      ;; POP
      (3 (if (not (null *stack*))
           (setf-register (pelt 1) (pop *stack*))
           (error "Stack is Empty! Error when writing to register ~a"
             (get-register (pelt 1) *registry*))))
      ;; EQ
      (4 (setf-register (pelt 1)
           (if (= (pelt 2) (pelt 3))
             1 0)))
      ;; GT
      (5 (setf-register (pelt 1)
           (if (> (pelt 2) (pelt 3))
             1 0)))
      ;; JMP
      (6 (setf num (pelt 1)))
      ;; JT
      (7 (when (not (zerop (pelt 1)))
           (setf num (pelt 2))))
      ;; JF
      (8 (when (zerop (pelt 1))
           (setf num (pelt 2))))
      ;; ADD
      (9 (setf-register (pelt 1)
           (mod (+ (pelt 2) (pelt 3)) 32768)))
      ;; MULT
      (10 (setf-register (pelt 1)
            (mod (* (pelt 2) (pelt 3)) 32768)))
      ;; MOD
      (11 (setf-register (pelt 1)
            (rem (pelt 2) (pelt 3))))
      ;; AND
      (12 (setf-register (pelt 1)
            (logand (pelt 2) (pelt 3))))
      ;; OR
      (13 (setf-register (pelt 1)
            (logior (pelt 2) (pelt 3))))
      ;; TODO: NOT
      ;; (14)
      ;; TODO: RMEM
      ;; (15 (setf-register (pelt 1) (get-register (pelt 2) *registry*)))
      ;; TODO: WMEM
      ;; (16)
      ;; CALL
      (17 (push (1+ num) *stack*)
          (setf num (pelt 1)))
      ;; RET
      (18 (if (not (null *stack*))
            (setf num (pop *stack*))
            (return-from run-program 'HALT)))
      ;; OUT
      (19 (format t "~A" (code-char (pelt 1))))
      ;; IN
      (20 (setf-register (pelt 1) (char-code (read-char))))
      ;; NO-OP
      (21)
      (otherwise 'INTERESTING))

    (incf *instruction*)))















;; (defun read-program (stream &optional (eof-error-p t) eof-value)
;;   "Read a number from a stream"
;;   (let ((num (peek-char t stream eof-error-p :eof)))
;;     (case num
;;       (:eof eof-value)
;;       (0 (return-from ))
;;       (1 nil))))
















;; (defun parse-bytes ()
;;   (b:with-open-binary-file (in *bin-file*
;;                              :if-does-not-exist :error)
;;     (print (b:read-integer 2 in :byte-order :little-endian))
;;     (print (b:read-integer 2 in :byte-order :little-endian))
;;     (print (b:read-integer 2 in :byte-order :little-endian))))
