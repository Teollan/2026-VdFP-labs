(defun sort-selection-imperative (lst-in)
  (let ((lst (copy-list lst-in)) (n (length lst-in)))
    (do ((i 0 (1+ i)))
        ((>= i (1- n)) lst)
      (do ((j (1+ i) (1+ j)) (min-idx i))
          ((>= j n) (rotatef (nth i lst) (nth min-idx lst)))
        (when (< (nth j lst) (nth min-idx lst)) (setq min-idx j))))))

; TESTS
(defmacro test (description expr)
  `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defmacro expect (actual expected)
  `(equal ,actual ,expected))

(test "empty list" (expect (sort-selection-imperative nil) nil))
(test "single element" (expect (sort-selection-imperative '(1)) '(1)))

(test "two elements, unsorted" (expect (sort-selection-imperative '(2 1)) '(1 2)))
(test "two elements, sorted" (expect (sort-selection-imperative '(1 2)) '(1 2)))

(test "already sorted" (expect (sort-selection-imperative '(1 2 3 4 5)) '(1 2 3 4 5)))
(test "reverse sorted" (expect (sort-selection-imperative '(5 4 3 2 1)) '(1 2 3 4 5)))
(test "unsorted" (expect (sort-selection-imperative '(3 1 4 5 2)) '(1 2 3 4 5)))

(test "duplicates" (expect (sort-selection-imperative '(2 3 1 2 1)) '(1 1 2 2 3)))
(test "all equal" (expect (sort-selection-imperative '(7 7 7)) '(7 7 7)))
(test "negatives and zero" (expect (sort-selection-imperative '(-1 3 0 -5)) '(-5 -1 0 3)))
(test "mixed number types" (expect (sort-selection-imperative '(3/2 -2 1 0.5)) '(-2 0.5 1 3/2)))

(test "input list is not modified"
      (let ((input (list 3 1 2)))
        (sort-selection-imperative input)
        (expect input '(3 1 2))))
