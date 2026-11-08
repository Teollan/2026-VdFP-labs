(in-package :lab5)

(defun calculate-widths-by-key (keys rows)
  (mapcar (lambda (key)
            (cons
              key
              (reduce #'max
                (cons
                  (length (princ-to-string key))
                  (mapcar (lambda (row)
                            (let ((value (cdr (assoc key row))))
                              (if (null value) 0 (length (princ-to-string value)))))
                      rows)))))
      keys))

(defun print-separator (widths-by-key)
  (format t "+~{~a~^+~}+~%"
    (mapcar (lambda (record)
              (let ((width (+ (cdr record) 2)))
                (format nil "~v,,,'-a" width "")))
        widths-by-key)))

(defun print-header-row (widths-by-key)
  (format t "|~{~a~^|~}|~%"
    (mapcar (lambda (record)
              (let ((width (cdr record))
                    (value (princ-to-string (car record))))
                (format nil " ~va " width value)))
        widths-by-key)))

(defun print-data-row (row widths-by-key)
  (format t "|~{~a~^|~}|~%"
    (mapcar (lambda (record)
              (let* ((key (car record))
                     (width (cdr record))
                     (raw-value (cdr (assoc key row)))
                     (value (if (null raw-value) "" (princ-to-string raw-value))))
                (format nil " ~va " width value)))
        widths-by-key)))

(defun print-rows (rows)
  (let* ((keys (mapcar #'car (first rows)))
         (widths (calculate-widths-by-key keys rows)))
    (print-separator widths)
    (print-header-row widths)
    (print-separator widths)
    (loop for row in rows
          do (print-data-row row widths))
    (print-separator widths)))
