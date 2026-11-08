(in-package :lab5/tests)
(in-suite lab5-tests)

(test insert-round-trip
  (with-temp-path (path)
    (insert (create-table path *project-schema*) (list *sample-project*))
    (is (equal (list *sample-project*)
               (funcall (select path *project-schema*))))))

(test insert-uses-header-column-order
  (with-temp-path (path)
    (insert (create-table path *project-schema*)
            '(((:available-model-ids 3 4)
               (:name . "Shuffled")
               (:id . 5)
               (:active-model-id . 3))))
    (is (equal "5;Shuffled;3;(3 4)" (second (file-lines path))))))

(test insert-appends-multiple-records
  (with-temp-path (path)
    (create-table path *project-schema*)
    (insert path (list *sample-project*))
    (insert path (list *sample-project* *sample-project*))
    (is (= 3 (length (funcall (select path *project-schema*)))))))

(test insert-empty-value-as-empty-cell
  (with-temp-path (path)
    (insert (create-table path *ai-model-schema*)
            '(((:id . 1) (:name . "Local") (:api-endpoint . "http://x")
               (:cost-per-100k-tokens))))
    (is (equal "1;Local;http://x;" (second (file-lines path))))
    (is (null (field :cost-per-100k-tokens
                     (first (funcall (select path *ai-model-schema*))))))))

(test insert-selection-into-new-table
  (with-temp-path (path)
    (insert (create-table path *ai-model-schema*) (models :id 7))
    (is (equal (models :id 7)
               (funcall (select path *ai-model-schema*))))))
