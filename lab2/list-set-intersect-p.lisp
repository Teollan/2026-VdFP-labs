(defun list-set-intersect-p (a b)
  (cond
   ((null a) NIL)
   ((value-set-intersect-p (first a) b))
   (T (list-set-intersect-p (rest a) b))))

(defun value-set-intersect-p (a b)
  (cond
   ((null b) NIL)
   ((eql a (first b)) T)
   (T (value-set-intersect-p a (rest b)))))

; TESTS
(defmacro test (description expr)
  `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defmacro expect (actual expected)
  `(equal ,actual ,expected))

;; the examples from the task statement
(test "task statement example: disjoint" (expect (list-set-intersect-p '(1 2 3) '(4 5 6)) NIL))
(test "task statement example: intersecting" (expect (list-set-intersect-p '(1 2 3) '(3 4 5)) T))

;; the match is found at the far end of both searches
(test "match at head of a and tail of b" (expect (list-set-intersect-p '(1 2 3) '(4 5 1)) T))

;; edge cases
(test "nil is matched as an element" (expect (list-set-intersect-p '(nil) '(nil)) T))
(test "a is empty" (expect (list-set-intersect-p nil '(1 2 3)) NIL))
(test "b is empty" (expect (list-set-intersect-p '(1 2 3) nil) NIL))

;; properties
(test "result is symmetric"
      (expect
        (list-set-intersect-p '(1 2 3) '(3 4))
        (list-set-intersect-p '(3 4) '(1 2 3))))
