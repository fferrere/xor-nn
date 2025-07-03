(asdf:defsystem #:xor-nn
  :author "Frédéric Ferrère"
  :description "Neural Network"
  :version "1.0.0"
  :license "MIT"
  :serial t
  :depends-on ()
  :components ((:file "package")
               (:file "xor"))
   :in-order-to ((test-op (test-op :xor-nn/test))))

(defsystem "xor-nn/test"
  :serial t
  :depends-on (:parachute :xor-nn)
  :components ((:module "tests"
		:components ((:file "package")
			     (:file "test"))))
  :perform (test-op (op c)
                    (symbol-call :parachute :test :xor-nn/test)))
  
