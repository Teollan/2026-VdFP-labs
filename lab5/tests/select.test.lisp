(in-package :lab5/tests)
(in-suite lab5-tests)

(test select-all
  (is (= 7 (length (projects))))
  (is (= 8 (length (models)))))

(test select-parses-types
  (let ((project (first (projects :id 1)))
        (model (first (models :id 7))))
    (is (integerp (field :id project)))
    (is (stringp (field :name project)))
    (is (equal '(1 2 3) (field :available-model-ids project)))
    (is (floatp (field :cost-per-100k-tokens model)))))

(test select-empty-optional-field
  (is (null (field :cost-per-100k-tokens (first (models :id 8))))))

(test select-by-value
  (is (equal "Codestral" (field :name (first (models :id 7)))))
  (is (= 7 (field :id (first (models :name "Codestral"))))))

(test select-by-predicate
  (let ((cheap (models :cost-per-100k-tokens (lambda (c) (and c (< c 0.02))))))
    (is (equal '(1 3 6) (mapcar (lambda (m) (field :id m)) cheap)))))

(test select-combined-filters
  (is (= 1 (length (projects :id 1 :active-model-id 2))))
  (is (null (projects :id 1 :active-model-id 3))))

(test select-no-match
  (is (null (projects :id 999))))

(test select-records-are-alists
  (let ((project (first (projects :id 1))))
    (is (every #'consp project))
    (is (equal '(:id :name :active-model-id :available-model-ids)
               (mapcar #'car project)))))
