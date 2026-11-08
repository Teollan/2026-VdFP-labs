(in-package :lab5)

(defun insert (to records)
  (let ((keys (with-open-file (table to :direction :input) (parse-key-row (read-line table)))))
    (with-open-file (table to :direction :output :if-exists :append)
      (format table "~{~A~%~}"
        (mapcar
            (lambda (record)
              (format nil "~{~A~^;~}"
                (mapcar
                    (lambda (key)
                      (let ((value (cdr (assoc key record))))
                        (typecase value
                          (null "")
                          (t (princ-to-string value)))))
                    keys)))
            records)))))
