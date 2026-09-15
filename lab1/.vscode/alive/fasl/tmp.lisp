;; Task 2
(setq *l* (let ((x '(4))) (list x 'D 'E (append '(6 5) x))))

(eq (first *l*) (last (fourth *l*)))
