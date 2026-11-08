(asdf:defsystem :lab5
  :description "Lab 5: a simple CSV-backed database of AI projects and models"
  :depends-on (:str :parse-float)
  :pathname "src"
  :serial t
  :components ((:file "package")
               (:file "schemas")
               (:file "csv")
               (:file "select")
               (:file "insert")
               (:file "create-table")
               (:file "convert")
               (:file "pretty"))
  :in-order-to ((test-op (test-op :lab5/tests))))

(asdf:defsystem :lab5/tests
  :depends-on (:lab5 :str :fiveam)
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "helpers")
               (:file "schemas.test")
               (:file "select.test")
               (:file "create-table.test")
               (:file "insert.test")
               (:file "convert.test")
               (:file "pretty.test"))
  :perform (test-op (o c)
             (uiop:symbol-call :fiveam :run! (uiop:find-symbol* :lab5-tests :lab5/tests))))
