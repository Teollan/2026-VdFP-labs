(in-package :lab5)

(defun alist-to-htable (alist)
  (let ((htable (make-hash-table :size (length alist))))
    (loop for (key . value) in alist
          do (setf (gethash key htable) value)
          finally (return htable))))
