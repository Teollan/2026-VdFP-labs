(in-package :lab5/tests)
(in-suite lab5-tests)

(defun printed (rows)
  (with-output-to-string (*standard-output*)
    (print-rows rows)))

(test print-rows-layout
  (let ((lines (str:lines (printed (models :id 7)))))
    (is (= 5 (length lines)))
    (is (search "| ID |" (second lines)))
    (is (search "Codestral" (fourth lines)))
    (is (= 1 (length (remove-duplicates (mapcar #'length lines)))))))

(test print-rows-empty-value-is-blank
  (let ((output (printed (models :id 8))))
    (is (null (search "NIL" output)))))
