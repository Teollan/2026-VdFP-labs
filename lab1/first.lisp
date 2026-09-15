;; Task 1

;; Create list
(setq *l* (list 'A 1 (list 2 'B (list 3)) () 'C))

;; Get elements
(first *l*)
(rest *l*)
(third *l*)
(car (last *l*))

;; Check if atom
(atom (first *l*))
(atom (second *l*))
(atom (third *l*))

;; Check if list
(listp (first *l*))
(listp (third *l*))
(listp (fourth *l*))

;; Random predicates
(numberp (first *l*))
(evenp (second *l*))
(null (fourth *l*))

;; Append lists
(append *l* (third *l*))