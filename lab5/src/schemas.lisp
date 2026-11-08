(in-package :lab5)

(defun make-list-parser (item-parser)
  (lambda (line)
    (mapcar item-parser
        (str:split " " (string-trim "() " line) :omit-nulls t))))

(defun make-optional-parser (item-parser)
  (lambda (line)
    (if (= (length line) 0)
        nil
        (funcall item-parser line))))

(defvar *project-schema*
        `((:id . ,#'parse-integer)
          (:name . ,#'identity)
          (:active-model-id . ,#'parse-integer)
          (:available-model-ids . ,(make-list-parser #'parse-integer))))

(defvar *ai-model-schema*
        `((:id . ,#'parse-integer)
          (:name . ,#'identity)
          (:api-endpoint . ,#'identity)
          (:cost-per-100k-tokens . ,(make-optional-parser #'parse-float:parse-float))))
