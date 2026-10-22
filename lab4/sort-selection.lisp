(defun sort-selection (lst &key (key #'identity) (test #'min))
  (if (null lst)
      nil
      (let ((selected (reduce (lambda (item acc)
                                (if (funcall test (funcall key item) (funcall key acc))
                                    item
                                    acc))
                          lst)))
        (cons selected (sort-selection (remove selected lst :count 1) :key key :test test)))))


; TESTS
(defmacro test (description expr)
  `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defmacro expect (actual expected)
  `(equal ,actual ,expected))

(test "empty list" (expect (sort-selection nil) nil))
(test "single element" (expect (sort-selection '(1)) '(1)))

(test "two elements, unsorted" (expect (sort-selection '(2 1)) '(1 2)))
(test "two elements, sorted" (expect (sort-selection '(1 2)) '(1 2)))

(test "already sorted" (expect (sort-selection '(1 2 3 4 5)) '(1 2 3 4 5)))
(test "reverse sorted" (expect (sort-selection '(5 4 3 2 1)) '(1 2 3 4 5)))
(test "unsorted" (expect (sort-selection '(3 1 4 5 2)) '(1 2 3 4 5)))

(test "duplicates" (expect (sort-selection '(2 3 1 2 1)) '(1 1 2 2 3)))
(test "all equal" (expect (sort-selection '(7 7 7)) '(7 7 7)))
(test "negatives and zero" (expect (sort-selection '(-1 3 0 -5)) '(-5 -1 0 3)))
(test "mixed number types" (expect (sort-selection '(3/2 -2 1 0.5)) '(-2 0.5 1 3/2)))

(test "input list is not modified"
      (let ((input (list 3 1 2)))
        (sort-selection input)
        (expect input '(3 1 2))))

(test "explicit :test #'<" (expect (sort-selection '(3 1 2) :test #'<) '(1 2 3)))
(test ":test #'> sorts descending" (expect (sort-selection '(3 1 4 5 2) :test #'>) '(5 4 3 2 1)))
(test ":test on strings" (expect (sort-selection '("b" "c" "a") :test #'string<) '("a" "b" "c")))

(test ":key returns original elements, not keys"
      (expect (sort-selection '((3 c) (1 a) (2 b)) :key #'first) '((1 a) (2 b) (3 c))))
(test ":key #'abs" (expect (sort-selection '(-3 1 -2) :key #'abs) '(1 -2 -3)))
(test ":key with :test"
      (expect (sort-selection '("bb" "a" "ccc") :key #'length :test #'>) '("ccc" "bb" "a")))
(test ":key with equal keys keeps all elements"
      (let ((result (sort-selection '((2 a) (1 b) (2 c) (1 d)) :key #'first)))
        (and (expect (mapcar #'first result) '(1 1 2 2))
             (expect (length result) 4)
             (every (lambda (x) (member x result :test #'equal)) '((2 a) (1 b) (2 c) (1 d))))))
(test ":key on empty list" (expect (sort-selection nil :key #'first) nil))

(test ":key is called once per element"
      (let ((calls 0))
        (sort-selection '(5 3 4 1 2) :key (lambda (x) (incf calls) x))
        (expect calls 5)))

(test "input list is not modified with :key and :test"
      (let ((input (list '(3 c) '(1 a) '(2 b))))
        (sort-selection input :key #'first :test #'>)
        (expect input '((3 c) (1 a) (2 b)))))
