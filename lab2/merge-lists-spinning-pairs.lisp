(defun merge-lists-spinning-pairs (a b)
    (cond
        ((and (null a) (null b)) nil)
        ((null a) (list-of-lists b))
        ((null b) (list-of-lists a))
        (t (list* (list (first a) (first b)) (merge-lists-spinning-pairs (rest b) (rest a))))
    )
)

(defun list-of-lists (items)
    (cond
        ((null items) nil) 
        (t (list* (list (first items)) (list-of-lists (rest items))))
    )
)

; TESTS
(defmacro test (description expr)
    `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr)
)

(defmacro expect (actual expected)
    `(equal ,actual ,expected)
)

;; the example from the task statement
(test "task statement example"
    (expect
        (merge-lists-spinning-pairs '(1 2 3 4 5) '(a b c d))
        '((1 A) (B 2) (3 C) (D 4) (5))
    )
)

;; equal lengths, so the recursion ends with both lists exhausted at once
(test "equal lengths" (expect (merge-lists-spinning-pairs '(1 2) '(a b)) '((1 A) (B 2))))

;; the example above leaves a tail of `a' behind, this one leaves a tail of `b'
(test "b is longer" (expect (merge-lists-spinning-pairs '(1 2) '(a b c d)) '((1 A) (B 2) (C) (D))))

;; empty lists
(test "a is empty" (expect (merge-lists-spinning-pairs nil '(a b c)) '((A) (B) (C))))
(test "b is empty" (expect (merge-lists-spinning-pairs '(1 2 3) nil) '((1) (2) (3))))

(test "nil as an element" (expect (merge-lists-spinning-pairs '(nil 2) '(a b)) '((NIL A) (B 2))))