(in-package :lab5)

(defun create-table (path schema)
  (with-open-file (table path :direction :output
                              :if-exists :error
                              :if-does-not-exist :create)
    (format table "~{~(~a~)~^;~}~%" (mapcar #'car schema)))
  path)
