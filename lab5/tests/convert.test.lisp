(in-package :lab5/tests)
(in-suite lab5-tests)

(test alist-to-htable-converts-record
  (let* ((project (first (projects :id 1)))
         (table (alist-to-htable project)))
    (is (hash-table-p table))
    (is (= (length project) (hash-table-count table)))
    (is (equal '(1 2 3) (gethash :available-model-ids table)))
    (is (equal "Customer Support Bot" (gethash :name table)))))

(test alist-to-htable-empty
  (is (zerop (hash-table-count (alist-to-htable nil)))))
