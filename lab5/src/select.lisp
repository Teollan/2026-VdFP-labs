(in-package :lab5)

(defun does-row-match (row filters)
  (loop for (key expected) on filters by #'cddr
        for actual = (cdr (assoc key row))
          always (if (functionp expected)
                     (funcall expected actual)
                     (equal expected actual))))

(defun select (from schema)
  (lambda (&rest filters)
    (with-open-file (table from :direction :input)
      (let ((keys (parse-key-row (read-line table))))
        (remove-if-not (lambda (row) (does-row-match row filters))
            (loop for line = (read-line table nil)
                  while line
                  collect (parse-data-row line keys schema)))))))
