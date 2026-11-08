(in-package :lab5/tests)
(in-suite lab5-tests)

(test create-table-writes-header
  (with-temp-path (path)
    (create-table path *ai-model-schema*)
    (is (equal '("id;name;api-endpoint;cost-per-100k-tokens")
               (file-lines path)))))

(test create-table-returns-path
  (with-temp-path (path)
    (is (equal path (create-table path *project-schema*)))))

(test create-table-refuses-to-overwrite
  (with-temp-path (path)
    (create-table path *project-schema*)
    (signals file-error (create-table path *project-schema*))
    (is (= 1 (length (file-lines path))))))
