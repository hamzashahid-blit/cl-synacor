(asdf:defsystem "cl-synacor"
  :version "0.1.0"
  :author "Hamza Shahid"
  :license "BSD 2 Clause License"
  :depends-on ("alexandria"
               "lisp-binary")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description "The Synacor Challenge in CL"
  :in-order-to ((asdf:test-op (asdf:test-op "cl-synacor/tests"))))

(asdf:defsystem "cl-synacor/tests"
  :author "Hamza Shahid"
  :license "BSD 2 Clause License"
  :depends-on ("cl-synacor"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-synacor"
  :perform (asdf:test-op (op c) (symbol-call :rove :run c)))
