(defun sort-selection-functional (lst)
    (if (null (rest lst))
        lst
        (let ((swapped-lst (swap-with-first lst (find-min-index lst))))
            (cons (first swapped-lst) (sort-selection-functional (rest swapped-lst))))))

(defun find-min-index (lst)
    (if (null (rest lst))
        0
        (let ((rest-min-index (find-min-index (rest lst))))
            (if (< (first lst) (nth (1+ rest-min-index) lst))
                0
                (1+ rest-min-index)))))

(defun swap-with-first (lst index)
    (if (= index 0)
        lst
        (append
            (list (nth index lst))
            (subseq lst 1 index)
            (list (first lst))
            (nthcdr (1+ index) lst))))

; TESTS
(defmacro test (description expr)
    `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defmacro expect (actual expected)
    `(equal ,actual ,expected))

(test "empty list" (expect (sort-selection-functional nil) nil))
(test "single element" (expect (sort-selection-functional '(1)) '(1)))

(test "two elements, unsorted" (expect (sort-selection-functional '(2 1)) '(1 2)))
(test "two elements, sorted" (expect (sort-selection-functional '(1 2)) '(1 2)))

(test "already sorted" (expect (sort-selection-functional '(1 2 3 4 5)) '(1 2 3 4 5)))
(test "reverse sorted" (expect (sort-selection-functional '(5 4 3 2 1)) '(1 2 3 4 5)))
(test "unsorted" (expect (sort-selection-functional '(3 1 4 5 2)) '(1 2 3 4 5)))

(test "duplicates" (expect (sort-selection-functional '(2 3 1 2 1)) '(1 1 2 2 3)))
(test "all equal" (expect (sort-selection-functional '(7 7 7)) '(7 7 7)))
(test "negatives and zero" (expect (sort-selection-functional '(-1 3 0 -5)) '(-5 -1 0 3)))
(test "mixed number types" (expect (sort-selection-functional '(3/2 -2 1 0.5)) '(-2 0.5 1 3/2)))

(test "input list is not modified"
    (let ((input (list 3 1 2)))
        (sort-selection-functional input)
        (expect input '(3 1 2))))
