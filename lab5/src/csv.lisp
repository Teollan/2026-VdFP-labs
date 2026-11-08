(in-package :lab5)

(defun parse-key-row (line)
  (mapcar
      (lambda (key-string)
        (intern (string-upcase (string-left-trim ":" key-string)) :keyword))
      (str:split ";" line)))

(defun parse-data-row (line keys schema)
  (let* ((raw-values (str:split ";" line))
         (raw-entries (pairlis keys raw-values)))
    (mapcar (lambda (schema-entry)
              (let* ((key (car schema-entry))
                     (parser (cdr schema-entry))
                     (raw-value (cdr (assoc key raw-entries))))
                (cons key (funcall parser raw-value))))
        schema)))
