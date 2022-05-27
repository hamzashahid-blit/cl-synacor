(defpackage cl-synacor/tests/main
  (:use :cl
        :cl-synacor
        :rove))
(in-package :cl-synacor/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-synacor)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
