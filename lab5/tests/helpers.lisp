(in-package :lab5/tests)

(defun data-file (name)
  (asdf:system-relative-pathname :lab5 (concatenate 'string "db/" name)))

(defmacro with-temp-path ((var) &body body)
  "Bind VAR to a unique, not-yet-existing path in the temp directory and
   delete that file afterwards, even if BODY signals an error."
  `(let ((,var (merge-pathnames
                 (format nil "lab5-test-~36r.csv"
                         (random (expt 36 8) (make-random-state t)))
                 (uiop:temporary-directory))))
     (unwind-protect (progn ,@body)
       (when (probe-file ,var) (delete-file ,var)))))

(defun field (key record)
  (cdr (assoc key record)))

(defun projects (&rest filters)
  (apply (select (data-file "projects.csv") *project-schema*) filters))

(defun models (&rest filters)
  (apply (select (data-file "ai-models.csv") *ai-model-schema*) filters))

(defun file-lines (path)
  (str:lines (str:from-file path)))

(defparameter *sample-project*
  '((:id . 100)
    (:name . "Test Project")
    (:active-model-id . 1)
    (:available-model-ids 1 2)))
