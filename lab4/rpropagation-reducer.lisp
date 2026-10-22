(defun rpropagation-reducer (&key (comparator #'<))
  (lambda (item acc)
    (if (and acc (not (funcall comparator item (first acc))))
        (cons (first acc) acc)
        (cons item acc))))

; TESTS
(defmacro test (description expr)
  `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defmacro expect (actual expected)
  `(equal ,actual ,expected))

(defun rpropagate (lst &rest reducer-args)
  (reduce (apply #'rpropagation-reducer reducer-args) lst
    :from-end t :initial-value nil))

(test "spec example 1" (expect (rpropagate '(3 2 1 2 3)) '(1 1 1 2 3)))
(test "spec example 2" (expect (rpropagate '(3 1 4 2)) '(1 1 2 2)))
(test "spec example 3" (expect (rpropagate '(1 2 3) :comparator #'>) '(3 3 3)))

(test "empty list" (expect (rpropagate nil) nil))
(test "single element" (expect (rpropagate '(5)) '(5)))

(test "nothing to propagate" (expect (rpropagate '(1 2 3)) '(1 2 3)))
(test "everything propagated" (expect (rpropagate '(3 2 1)) '(1 1 1)))
(test "all equal" (expect (rpropagate '(7 7 7)) '(7 7 7)))
(test "negatives and zero" (expect (rpropagate '(0 -1 5 -3 2)) '(-3 -3 -3 -3 2)))

(test "custom comparator on strings"
      (expect (rpropagate '("b" "c" "a" "d") :comparator #'string<) '("a" "a" "a" "d")))
(test "equal by comparator but different values, not better -> replaced"
      (expect (rpropagate '(-1 1) :comparator (lambda (a b) (< (abs a) (abs b)))) '(1 1)))

(test "reducer can be reused"
      (let ((reducer (rpropagation-reducer)))
        (reduce reducer '(3 1 2) :from-end t :initial-value nil)
        (expect (reduce reducer '(3 1 2) :from-end t :initial-value nil) '(1 1 2))))

(test "input list is not modified"
      (let ((input (list 3 1 2)))
        (rpropagate input)
        (expect input '(3 1 2))))
