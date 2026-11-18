(defun f (i)
  (cond
   ((or (= i 1) (= i 6))
     1)
   ((<= 2 i 5)
     (* (sqrt (f (1- i))) (/ (log i) 7)))
   ((<= 7 i 15)
     (* (sqrt (f (1- i))) (/ (sqrt i) 4)))
   (t
     nil)))

(defmacro test (description expr)
  `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defun approx-equal (actual expected)
  (<= (abs (- actual expected)) 1e-6))

;;; Expected values computed in Wolfram Cloud.

;; simple case f(1)
(test "f(1) = 1" (approx-equal (f 1) 1))

;; first branch, i = 2..5
(test "f(2)" (approx-equal (f 2) 0.09902102579427790d0))
(test "f(3)" (approx-equal (f 3) 0.04938671311461513d0))
(test "f(4)" (approx-equal (f 4) 0.04401112583216574d0))
(test "f(5)" (approx-equal (f 5) 0.04823446064062631d0))

;; simple case f(6)
(test "f(6) = 1" (approx-equal (f 6) 1))

;; second branch, i = 7..15
(test "f(7)" (approx-equal (f 7) 0.6614378277661476d0))
(test "f(8)" (approx-equal (f 8) 0.5750816584478015d0))
(test "f(9)" (approx-equal (f 9) 0.5687560398596997d0))
(test "f(10)" (approx-equal (f 10) 0.5962151666238560d0))
(test "f(11)" (approx-equal (f 11) 0.6402327132019270d0))
(test "f(12)" (approx-equal (f 12) 0.6929462712948568d0))
(test "f(13)" (approx-equal (f 13) 0.7503458172250120d0))
(test "f(14)" (approx-equal (f 14) 0.8102793284243931d0))
(test "f(15)" (approx-equal (f 15) 0.8715714947139268d0))

;; outside the domain
(test "f(0) = NIL" (null (f 0)))
(test "f(16) = NIL" (null (f 16)))
(test "f(-1) = NIL" (null (f -1)))
