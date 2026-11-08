<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПСПМ СПіСКС</b></p>

<p align="center">
<b>Звіт з лабораторної роботи 5</b><br/>
"Робота з базою даних"<br/>
дисципліни "Вступ до функціонального програмування"
</p>

<p align="right"><b>Студент</b>: Козлов Сергій Олександрович група КВ-33</p>
<p align="right"><b>Рік</b>: 2026</p>

## Загальне завдання
В роботі необхідно реалізувати утиліти для роботи з базою даних, заданою за
варіантом. База даних складається з кількох таблиць. Таблиці представлені у
вигляді CSV файлів. При зчитуванні записів з таблиць, кожен запис має бути
представлений певним типом в залежності від варіанту: структурою, асоціативним
списком або геш-таблицею.

1. Визначити структури та/або утиліти для створення записів з таблиць (в
залежності від типу записів, заданого варіантом).
2. Розробити утиліту(-и) для зчитування таблиць з файлів. Значення колонок мають
бути розібрані відповідно до типу даних у них.
3. Розробити функцію `select`, яка отримує на вхід шлях до файлу з таблицею, а
також якийсь об'єкт, який дасть змогу зчитати записи конкретного типу або
структури. `select` повертає лямбда-вираз, який, в разі виклику, виконує
"вибірку" записів з таблиці. Лямбда-вираз в якості ключових параметрів може
отримати на вхід значення полів записів таблиці, для того щоб обмежити вибірку
лише заданими значеннями (виконати фільтрування). Вибірка повертається у вигляді
списку записів.
4. Написати утиліту(-и) для запису вибірки (списку записів) у файл.
5. Написати функції для конвертування записів у інший тип (асоціативні списки у
геш-таблиці).
6. Написати функцію(-ї) для "красивого" виводу записів таблиці (pretty-print).

## Варіант 6
База даних: **Проєкти із застосуванням ШІ** — база даних моделей штучного
інтелекту та проєктів, в яких вони використовуються.

Таблиці:
1. Проєкти (`db/projects.csv`): `id`, `name`, `active-model-id`,
`available-model-ids`.
2. Моделі штучного інтелекту (`db/ai-models.csv`): `id`, `name`,
`api-endpoint`, `cost-per-100k-tokens`.

Тип записів: **асоціативний список**.

Конвертування записів: **асоціативні списки у геш-таблиці**.

## Лістинг реалізації завдання

#### `lab5.lisp`
```lisp
(asdf:load-asd (merge-pathnames "lab5.asd" *load-truename*))
(ql:quickload :lab5)
```

#### `src/schemas.lisp`
```lisp
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
```

#### `src/csv.lisp`
```lisp
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
```

#### `src/select.lisp`
```lisp
(in-package :lab5)

(defun does-row-match (row filters)
  (loop for (key expected) on filters by #'cddr
        for actual = (cdr (assoc key row))
          always (if (functionp expected)
                     (funcall expected actual)
                     (equal expected actual))))

(defun select (from schema)
  (lambda (&rest filters)
    (with-open-file (table from :direction :input)
      (let ((keys (parse-key-row (read-line table))))
        (remove-if-not (lambda (row) (does-row-match row filters))
            (loop for line = (read-line table nil)
                  while line
                  collect (parse-data-row line keys schema)))))))
```

#### `src/create-table.lisp`
```lisp
(in-package :lab5)

(defun create-table (path schema)
  (with-open-file (table path :direction :output
                              :if-exists :error
                              :if-does-not-exist :create)
    (format table "~{~(~a~)~^;~}~%" (mapcar #'car schema)))
  path)
```

#### `src/insert.lisp`
```lisp
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
```

#### `src/convert.lisp`
```lisp
(in-package :lab5)

(defun alist-to-htable (alist)
  (let ((htable (make-hash-table :size (length alist))))
    (loop for (key . value) in alist
          do (setf (gethash key htable) value)
          finally (return htable))))
```

#### `src/pretty.lisp`
```lisp
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
```

### Тестові набори та утиліти
Тести написано з використанням фреймворку FiveAM. Тести, що записують у файли,
працюють з тимчасовими файлами (`with-temp-path`), які видаляються після
виконання тесту, навіть у разі помилки. Таблиці з `db/` використовуються лише
для читання.

#### `tests/helpers.lisp`
```lisp
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
```

#### `tests/schemas.test.lisp`
```lisp
(in-package :lab5/tests)
(in-suite lab5-tests)

(test list-parser
  (let ((parse (make-list-parser #'parse-integer)))
    (is (equal '(1 2 3) (funcall parse "(1 2 3)")))
    (is (equal '(5) (funcall parse "(5)")))
    (is (null (funcall parse "()")))
    (is (null (funcall parse "")))))

(test optional-parser
  (let ((parse (make-optional-parser #'parse-integer)))
    (is (= 42 (funcall parse "42")))
    (is (null (funcall parse "")))))
```

#### `tests/select.test.lisp`
```lisp
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
```

#### `tests/create-table.test.lisp`
```lisp
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
```

#### `tests/insert.test.lisp`
```lisp
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
```

#### `tests/convert.test.lisp`
```lisp
(in-package :lab5/tests)
(in-suite lab5-tests)

(test alist-to-htable-converts-record
  (let* ((project (first (projects :id 1)))
         (table (alist-to-htable project)))
    (is (hash-table-p table))
    (is (= (length project) (hash-table-count table)))
    (is (equal '(1 2 3) (gethash :available-model-ids table)))
    (is (equal "Customer Support Bot" (gethash :name table)))))

(test alist-to-htable-empty
  (is (zerop (hash-table-count (alist-to-htable nil)))))
```

#### `tests/pretty.test.lisp`
```lisp
(in-package :lab5/tests)
(in-suite lab5-tests)

(defun printed (rows)
  (with-output-to-string (*standard-output*)
    (print-rows rows)))

(test print-rows-layout
  (let ((lines (str:lines (printed (models :id 7)))))
    (is (= 5 (length lines)))
    (is (search "| ID |" (second lines)))
    (is (search "Codestral" (fourth lines)))
    (is (= 1 (length (remove-duplicates (mapcar #'length lines)))))))

(test print-rows-empty-value-is-blank
  (let ((output (printed (models :id 8))))
    (is (null (search "NIL" output)))))
```

### Тестові файли

#### `db/projects.csv`
```csv
id;name;active-model-id;available-model-ids
1;Customer Support Bot;2;(1 2 3)
2;Code Review Assistant;7;(7 2)
3;Product Image Tagger;5;(5)
4;Semantic Search Engine;6;(6 3)
5;Internal Docs Q&A;8;(8 1 6)
6;Marketing Copy Generator;4;(3 4)
7;Offline Translator;8;(8)
```

#### `db/ai-models.csv`
```csv
id;name;api-endpoint;cost-per-100k-tokens
1;GPT-4o mini;https://api.openai.com/v1/chat/completions;0.015
2;GPT-4o;https://api.openai.com/v1/chat/completions;0.25
3;Gemini 2.0 Flash;https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent;0.01
4;Claude Sonnet 4;https://api.anthropic.com/v1/messages;0.30
5;Gemini 2.5 Pro;https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent;0.125
6;text-embedding-3-small;https://api.openai.com/v1/embeddings;0.002
7;Codestral;https://api.mistral.ai/v1/chat/completions;0.03
8;Llama 3.1 8B;http://localhost:11434/api/chat;
```

### Тестування
```lisp
CL-USER> (load "lab5/lab5.lisp")
CL-USER> (asdf:test-system :lab5)
Running test suite LAB5-TESTS
 Running test LIST-PARSER ....
 Running test OPTIONAL-PARSER ..
 Running test SELECT-ALL ..
 Running test SELECT-PARSES-TYPES ....
 Running test SELECT-EMPTY-OPTIONAL-FIELD .
 Running test SELECT-BY-VALUE ..
 Running test SELECT-BY-PREDICATE .
 Running test SELECT-COMBINED-FILTERS ..
 Running test SELECT-NO-MATCH .
 Running test SELECT-RECORDS-ARE-ALISTS ..
 Running test CREATE-TABLE-WRITES-HEADER .
 Running test CREATE-TABLE-RETURNS-PATH .
 Running test CREATE-TABLE-REFUSES-TO-OVERWRITE ..
 Running test INSERT-ROUND-TRIP .
 Running test INSERT-USES-HEADER-COLUMN-ORDER .
 Running test INSERT-APPENDS-MULTIPLE-RECORDS .
 Running test INSERT-EMPTY-VALUE-AS-EMPTY-CELL ..
 Running test INSERT-SELECTION-INTO-NEW-TABLE .
 Running test ALIST-TO-HTABLE-CONVERTS-RECORD ....
 Running test ALIST-TO-HTABLE-EMPTY .
 Running test PRINT-ROWS-LAYOUT ....
 Running test PRINT-ROWS-EMPTY-VALUE-IS-BLANK .
 Did 41 checks.
    Pass: 41 (100%)
    Skip: 0 ( 0%)
    Fail: 0 ( 0%)
```

### Приклади використання
```lisp
LAB5> (FUNCALL (SELECT "db/projects.csv" *PROJECT-SCHEMA*) :ID 1)
(((:ID . 1) (:NAME . "Customer Support Bot") (:ACTIVE-MODEL-ID . 2)
  (:AVAILABLE-MODEL-IDS 1 2 3)))
LAB5> (FUNCALL (SELECT "db/ai-models.csv" *AI-MODEL-SCHEMA*) :NAME "Codestral")
(((:ID . 7) (:NAME . "Codestral")
  (:API-ENDPOINT . "https://api.mistral.ai/v1/chat/completions")
  (:COST-PER-100K-TOKENS . 0.03)))
LAB5> (PRINT-ROWS
       (FUNCALL (SELECT "db/projects.csv" *PROJECT-SCHEMA*) :ACTIVE-MODEL-ID 8))
+----+--------------------+-----------------+---------------------+
| ID | NAME               | ACTIVE-MODEL-ID | AVAILABLE-MODEL-IDS |
+----+--------------------+-----------------+---------------------+
| 5  | Internal Docs Q&A  | 8               | (8 1 6)             |
| 7  | Offline Translator | 8               | (8)                 |
+----+--------------------+-----------------+---------------------+
NIL
LAB5> (PRINT-ROWS
       (FUNCALL (SELECT "db/ai-models.csv" *AI-MODEL-SCHEMA*)
                :COST-PER-100K-TOKENS #'NULL))
+----+--------------+---------------------------------+----------------------+
| ID | NAME         | API-ENDPOINT                    | COST-PER-100K-TOKENS |
+----+--------------+---------------------------------+----------------------+
| 8  | Llama 3.1 8B | http://localhost:11434/api/chat |                      |
+----+--------------+---------------------------------+----------------------+
NIL
LAB5> (ALIST-TO-HTABLE
       (FIRST (FUNCALL (SELECT "db/projects.csv" *PROJECT-SCHEMA*) :ID 1)))
#<HASH-TABLE :TEST EQL :COUNT 4 {...}>
```
