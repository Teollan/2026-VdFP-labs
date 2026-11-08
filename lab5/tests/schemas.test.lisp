(in-package :lab5/tests)
(in-suite lab5-tests)

(test list-parser
  (let ((parse (make-list-parser #'parse-integer)))
    (is (equal '(1 2 3) (funcall parse "(1 2 3)")))
    (is (equal '(5) (funcall parse "(5)")))
    (is (null (funcall parse "()")))
    (is (null (funcall parse "")))))

(test optional-parser
  (let ((parse (make-optional-parser #'parse-integer)))
    (is (= 42 (funcall parse "42")))
    (is (null (funcall parse "")))))
