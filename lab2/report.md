<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПСПМ СПіСКС</b></p>

<p align="center">
<b>Звіт з лабораторної роботи 2</b><br/>
"Рекурсія"<br/>
дисципліни "Вступ до функціонального програмування"
</p>

<p align="right"><b>Студент</b>: Козлов Сергій Олександрович група КВ-33</p>
<p align="right"><b>Рік</b>: 2026</p>

## Загальне завдання
Реалізуйте дві рекурсивні функції, що виконують деякі дії з вхідним(и) списком(-ами), за
можливості/необхідності використовуючи різні види рекурсії. Функції, які необхідно
реалізувати, задаються варіантом. Вимоги до функцій:
1. Зміна списку згідно із завданням має відбуватись за рахунок конструювання нового
списку, а не зміни наявного (вхідного).
2. Не допускається використання функцій вищого порядку чи стандартних функцій
для роботи зі списками, що не наведені в четвертому розділі навчального
посібника.
3. Реалізована функція не має бути функцією вищого порядку, тобто приймати функції
в якості аргументів.
4. Не допускається використання псевдофункцій (деструктивного підходу).
5. Не допускається використання циклів.

Кожна реалізована функція має бути протестована для різних тестових наборів. Тести
мають бути оформленні у вигляді модульних тестів.

Додатковий бал за лабораторну роботу можна отримати в разі виконання всіх наступних
умов:
* робота виконана до дедлайну (включно з датою дедлайну)
* крім основних реалізацій функцій за варіантом, також реалізовано додатковий
варіант однієї чи обох функцій, який працюватиме швидше за основну реалізацію,
не порушуючи при цьому перші три вимоги до основної реалізації (вимоги 4 і 5
можуть бути порушені), за виключенням того, що в разі необхідності можна також
використати стандартну функцію copy-list

## Варіант 6
1. Написати функцію `merge-lists-spinning-pairs`, яка групує відповідні елементи
двох списків, почергово змінюючи їх взаємне розташування в групі:

    ```
    CL-USER> (merge-lists-spinning-pairs '(1 2 3 4 5) '(a b c d))
    ((1 A) (B 2) (3 C) (D 4) (5))
    ```

2. Написати предикат `list-set-intersect-p`, який визначає чи перетинаються дві
множини, задані списками атомів, чи ні:
    ```
    CL-USER> (list-set-intersect-p '(1 2 3) '(4 5 6))
    NIL
    CL-USER> (list-set-intersect-p '(1 2 3) '(3 4 5))
    T
    ```

## Лістинг функції `merge-lists-spinning-pairs`
```lisp
(defun merge-lists-spinning-pairs (a b)
    (cond
        ((and (null a) (null b)) nil)
        ((null a) (list-of-lists b))
        ((null b) (list-of-lists a))
        (t (list* (list (first a) (first b)) (merge-lists-spinning-pairs (rest b) (rest a))))
    )
)

(defun list-of-lists (items)
    (cond
        ((null items) nil) 
        (t (list* (list (first items)) (list-of-lists (rest items))))
    )
)
```

### Тестові набори та утиліти
```lisp
(defmacro test (description expr)
    `(format t "~a | ~:[~c[31mFAIL~;~c[32mPASS~]~c[0m ~%" ,description ,expr #\Escape #\Escape)
)

(defmacro expect (actual expected)
    `(equal ,actual ,expected)
)

;; the example from the task statement
(test "task statement example"
    (expect
        (merge-lists-spinning-pairs '(1 2 3 4 5) '(a b c d))
        '((1 A) (B 2) (3 C) (D 4) (5))
    )
)

;; equal lengths, so the recursion ends with both lists exhausted at once
(test "equal lengths" (expect (merge-lists-spinning-pairs '(1 2) '(a b)) '((1 A) (B 2))))

;; the example above leaves a tail of `a' behind, this one leaves a tail of `b'
(test "b is longer" (expect (merge-lists-spinning-pairs '(1 2) '(a b c d)) '((1 A) (B 2) (C) (D))))

;; empty lists
(test "a is empty" (expect (merge-lists-spinning-pairs nil '(a b c)) '((A) (B) (C))))
(test "b is empty" (expect (merge-lists-spinning-pairs '(1 2 3) nil) '((1) (2) (3))))

(test "nil as an element" (expect (merge-lists-spinning-pairs '(nil 2) '(a b)) '((NIL A) (B 2))))
```

### Тестування
```lisp
task statement example | PASS 
equal lengths | PASS 
b is longer | PASS 
a is empty | PASS 
b is empty | PASS 
nil as an element | PASS
```

## Лістинг функції `list-set-intersect-p`
```lisp
(defun list-set-intersect-p (a b)
    (cond
        ((null a) NIL)
        ((value-set-intersect-p (first a) b))
        (T (list-set-intersect-p (rest a) b))
    )
)

(defun value-set-intersect-p (a b)
    (cond
        ((null b) NIL)
        ((eql a (first b)) T)
        (T (value-set-intersect-p a (rest b)))
    )
)
```

### Тестові набори та утиліти
```lisp
(defmacro test (description expr)
    `(format t "~a | ~:[~c[31mFAIL~;~c[32mPASS~]~c[0m ~%" ,description ,expr #\Escape #\Escape)
)

(defmacro expect (actual expected)
    `(equal ,actual ,expected)
)

;; the examples from the task statement
(test "task statement example: disjoint" (expect (list-set-intersect-p '(1 2 3) '(4 5 6)) NIL))
(test "task statement example: intersecting" (expect (list-set-intersect-p '(1 2 3) '(3 4 5)) T))

;; the match is found at the far end of both searches
(test "match at head of a and tail of b" (expect (list-set-intersect-p '(1 2 3) '(4 5 1)) T))

;; edge cases
(test "nil is matched as an element" (expect (list-set-intersect-p '(nil) '(nil)) T))
(test "a is empty" (expect (list-set-intersect-p nil '(1 2 3)) NIL))
(test "b is empty" (expect (list-set-intersect-p '(1 2 3) nil) NIL))

;; properties
(test "result is symmetric"
    (expect
        (list-set-intersect-p '(1 2 3) '(3 4))
        (list-set-intersect-p '(3 4) '(1 2 3))
    )
)
```

### Тестування
```lisp
task statement example: disjoint | PASS 
task statement example: intersecting | PASS 
match at head of a and tail of b | PASS 
nil is matched as an element | PASS 
a is empty | PASS 
b is empty | PASS 
result is symmetric | PASS 
```