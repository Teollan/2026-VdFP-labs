<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПСПМ СПіСКС</b></p>

<p align="center">
<b>Звіт з лабораторної роботи 4</b><br/>
"Функції вищого порядку та замикання"<br/>
дисципліни "Вступ до функціонального програмування"
</p>

<p align="right"><b>Студент</b>: Козлов Сергій Олександрович група КВ-33</p>
<p align="right"><b>Рік</b>: 2026</p>

## Загальне завдання
Завдання складається з двох частин:
1. Переписати функціональну реалізацію алгоритму сортування з лабораторної
роботи 3 з такими змінами:
   - використати функції вищого порядку для роботи з послідовностями (де/якщо
   це доречно, в разі, якщо функції вищого порядку не були використані при
   реалізації л.р. №3);
   - додати до інтерфейсу функції (та використання в реалізації) два ключових
   параметра: `key` та `test`, що працюють аналогічно до того, як працюють
   параметри з такими назвами в функціях, що працюють з послідовностями. При
   цьому `key` має виконатись мінімальну кількість разів.
2. Реалізувати функцію, що створює замикання, яке працює згідно із завданням за
варіантом. Використання псевдофункцій не забороняється, але, за можливості, має
бути зменшене до необхідного мінімуму.

## Варіант першої частини 6
Алгоритм сортування вибором за незменшенням.

## Лістинг реалізації першої частини завдання
```lisp
(defun sort-selection (lst &key (key #'identity) (test #'<))
  (mapcar #'cdr (sort-pairs (mapcar (lambda (item) (cons (funcall key item) item)) lst) test)))

(defun sort-pairs (pairs test)
  (if (null pairs)
      nil
      (let ((selected (reduce (select-best test) pairs)))
        (cons selected (sort-pairs (remove selected pairs :count 1) test)))))

(defun select-best (test)
  (lambda (acc pair)
    (if (funcall test (car pair) (car acc))
        pair
        acc)))
```

### Тестові набори та утиліти першої частини
```lisp
(defmacro test (description expr)
  `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defmacro expect (actual expected)
  `(equal ,actual ,expected))

(test "empty list" (expect (sort-selection nil) nil))
(test "single element" (expect (sort-selection '(1)) '(1)))

(test "two elements, unsorted" (expect (sort-selection '(2 1)) '(1 2)))
(test "two elements, sorted" (expect (sort-selection '(1 2)) '(1 2)))

(test "already sorted" (expect (sort-selection '(1 2 3 4 5)) '(1 2 3 4 5)))
(test "reverse sorted" (expect (sort-selection '(5 4 3 2 1)) '(1 2 3 4 5)))
(test "unsorted" (expect (sort-selection '(3 1 4 5 2)) '(1 2 3 4 5)))

(test "duplicates" (expect (sort-selection '(2 3 1 2 1)) '(1 1 2 2 3)))
(test "all equal" (expect (sort-selection '(7 7 7)) '(7 7 7)))
(test "negatives and zero" (expect (sort-selection '(-1 3 0 -5)) '(-5 -1 0 3)))
(test "mixed number types" (expect (sort-selection '(3/2 -2 1 0.5)) '(-2 0.5 1 3/2)))

(test "input list is not modified"
      (let ((input (list 3 1 2)))
        (sort-selection input)
        (expect input '(3 1 2))))

(test "explicit :test #'<" (expect (sort-selection '(3 1 2) :test #'<) '(1 2 3)))
(test ":test #'> sorts descending" (expect (sort-selection '(3 1 4 5 2) :test #'>) '(5 4 3 2 1)))
(test ":test on strings" (expect (sort-selection '("b" "c" "a") :test #'string<) '("a" "b" "c")))

(test ":key returns original elements, not keys"
      (expect (sort-selection '((3 c) (1 a) (2 b)) :key #'first) '((1 a) (2 b) (3 c))))
(test ":key #'abs" (expect (sort-selection '(-3 1 -2) :key #'abs) '(1 -2 -3)))
(test ":key with :test"
      (expect (sort-selection '("bb" "a" "ccc") :key #'length :test #'>) '("ccc" "bb" "a")))
(test ":key with equal keys keeps all elements"
      (let ((result (sort-selection '((2 a) (1 b) (2 c) (1 d)) :key #'first)))
        (and (expect (mapcar #'first result) '(1 1 2 2))
             (expect (length result) 4)
             (every (lambda (x) (member x result :test #'equal)) '((2 a) (1 b) (2 c) (1 d))))))
(test ":key on empty list" (expect (sort-selection nil :key #'first) nil))

(test ":key is called once per element"
      (let ((calls 0))
        (sort-selection '(5 3 4 1 2) :key (lambda (x) (incf calls) x))
        (expect calls 5)))

(test "input list is not modified with :key and :test"
      (let ((input (list '(3 c) '(1 a) '(2 b))))
        (sort-selection input :key #'first :test #'>)
        (expect input '((3 c) (1 a) (2 b)))))
```

### Тестування першої частини
```lisp
empty list | PASS
single element | PASS
two elements, unsorted | PASS
two elements, sorted | PASS
already sorted | PASS
reverse sorted | PASS
unsorted | PASS
duplicates | PASS
all equal | PASS
negatives and zero | PASS
mixed number types | PASS
input list is not modified | PASS
explicit :test #'< | PASS
:test #'> sorts descending | PASS
:test on strings | PASS
:key returns original elements, not keys | PASS
:key #'abs | PASS
:key with :test | PASS
:key with equal keys keeps all elements | PASS
:key on empty list | PASS
:key is called once per element | PASS
input list is not modified with :key and :test | PASS
```

## Варіант другої частини 6
Написати функцію `rpropagation-reducer`, яка має один ключовий параметр —
функцію `comparator`. `rpropagation-reducer` має повернути функцію, яка при
застосуванні в якості першого аргумента `reduce` робить наступне: при обході
списку з кінця, якщо елемент списку-аргумента `reduce` не "кращий" за
попередній (той, що "справа") згідно з `comparator`, тоді він заміняється на
значення попереднього, тобто "кращого", елемента. Якщо ж він "кращий" за
попередній елемент згідно `comparator`, тоді заміна не відбувається. Функція
`comparator` за замовчуванням має значення `#'<`. Обмеження, які накладаються
на використання функції-результату `rpropagation-reducer` при передачі у
`reduce` визначаються розробником.

Обмеження на використання: функцію-результат необхідно передавати у `reduce`
з параметрами `:from-end t` та `:initial-value nil`.

## Лістинг реалізації другої частини завдання
```lisp
(defun rpropagation-reducer (&key (comparator #'<))
  (lambda (item acc)
    (if (and acc (not (funcall comparator item (first acc))))
        (cons (first acc) acc)
        (cons item acc))))
```

### Тестові набори та утиліти другої частини
```lisp
(defmacro test (description expr)
  `(format t "~a | ~:[FAIL~;PASS~]~%" ,description ,expr))

(defmacro expect (actual expected)
  `(equal ,actual ,expected))

(defun rpropagate (lst &rest reducer-args)
  (reduce (apply #'rpropagation-reducer reducer-args) lst
    :from-end t :initial-value nil))

(test "spec example 1" (expect (rpropagate '(3 2 1 2 3)) '(1 1 1 2 3)))
(test "spec example 2" (expect (rpropagate '(3 1 4 2)) '(1 1 2 2)))
(test "spec example 3" (expect (rpropagate '(1 2 3) :comparator #'>) '(3 3 3)))

(test "empty list" (expect (rpropagate nil) nil))
(test "single element" (expect (rpropagate '(5)) '(5)))

(test "nothing to propagate" (expect (rpropagate '(1 2 3)) '(1 2 3)))
(test "everything propagated" (expect (rpropagate '(3 2 1)) '(1 1 1)))
(test "all equal" (expect (rpropagate '(7 7 7)) '(7 7 7)))
(test "negatives and zero" (expect (rpropagate '(0 -1 5 -3 2)) '(-3 -3 -3 -3 2)))

(test "custom comparator on strings"
      (expect (rpropagate '("b" "c" "a" "d") :comparator #'string<) '("a" "a" "a" "d")))
(test "equal by comparator but different values, not better -> replaced"
      (expect (rpropagate '(-1 1) :comparator (lambda (a b) (< (abs a) (abs b)))) '(1 1)))

(test "reducer can be reused"
      (let ((reducer (rpropagation-reducer)))
        (reduce reducer '(3 1 2) :from-end t :initial-value nil)
        (expect (reduce reducer '(3 1 2) :from-end t :initial-value nil) '(1 1 2))))

(test "input list is not modified"
      (let ((input (list 3 1 2)))
        (rpropagate input)
        (expect input '(3 1 2))))
```

### Тестування другої частини
```lisp
spec example 1 | PASS
spec example 2 | PASS
spec example 3 | PASS
empty list | PASS
single element | PASS
nothing to propagate | PASS
everything propagated | PASS
all equal | PASS
negatives and zero | PASS
custom comparator on strings | PASS
equal by comparator but different values, not better -> replaced | PASS
reducer can be reused | PASS
input list is not modified | PASS
```
