#lang scheme
(define (read-f filename) (call-with-input-file filename
(lambda (input-port)
(let loop ((line (read-line input-port)))
(cond
 ((eof-object? line) '())
 (#t (begin (cons (string-split (clean-line line) ",") (loop (read-line input-port))))))))))

(define (format-resident lst)
  (list (car lst) (cadr lst) (caddr lst) (cdddr lst)))

(define (format-program lst)
  (list (car lst) (cadr lst) (string->number (caddr lst)) (map string->number(cdddr lst))))


(define (clean-line str)
  (list->string
   (filter (lambda (c) (not (or (char=? c #\") (char=? c #\[) (char=? c #\]) )))
           (string->list str))))

(define (read-residents filename)
(map (lambda(L) (format-resident (cons (string->number (car L)) (cdr L)))) (cdr (read-f filename))))

(define (read-programs filename)
(map format-program (cdr (read-f filename))))

