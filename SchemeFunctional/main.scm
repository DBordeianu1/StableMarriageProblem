#lang scheme
(require "rpReader.scm")
(define PLIST (read-programs "programSmall.csv"))
(define RLIST (read-residents "residentSmall.csv"))

; Returns the list of programs for a resident
(define (resRol L) (cadddr L))

; Returns the list of the program
(define (programRol L) (cadddr L))

; define quota as well

; Find the id of a resident
(define (resID L) (car L) )

; Find the id of a program
(define (programID L) (car L) )

#|
Returns the information associated to a resident from the list of residents

> (get-resident-info 574 RLIST)
(574 "Salvatore" "Williams" ("NRS" "HEP" "MMI"))
|#
(define (get-resident-info rid rlist)
(cond ((null? rlist) '())
((eq? rid (resID(car rlist))) (car rlist) )
(else (get-resident-info rid (cdr rlist)))
  )
  )

#|
Returns the info associated to a program from the program list

> (get-program-info "HEP" PLIST)
("HEP" "Hematological Pathology" 2 (403 574 913 616 226))
|#
(define (get-program-info pid plist)
(cond ((null? plist) '())
((string=? pid (programID(car plist))) (car plist) )
(else (get-program-info pid (cdr plist)))
     )
  )

#|
Returns the rank of a resident in the rol of a program, 0 being the 1st rank

> (rank 616 (get-program-info "HEP" PLIST))
3
|#
(define (rank rid pinfo)
  (rank-helper rid (programRol pinfo))  
)

(define (rank-helper rid rrol)
(cond ((null? rrol) -1)
((eq? rid (car rrol))0)
(else (+ 1 (rank-helper rid (cdr rrol))))
  )
  )

#|
Returns true if this program has been matched to a program

These tests were provided by the professor, but not useful if gale-shapley not implemented yet:
> (matched? 403 (gale-shapley RLIST PLIST '()))
#t
> (matched? 377 (gale-shapley RLIST PLIST '()))
#f

So here are some custom tests:
> (matched? 403 '((574 "NRS") (913 "MMI") (403 "HEP")))
#t
> (matched? 377 '((403 "HEP") (574 "NRS") (913 "MMI")))
#f
|#
(define (matched? rid matches)
(cond ((null? matches) #f)
((eq? rid (resID(car matches))) #t)
(else (matched? rid (cdr matches)))
  )
  )

#|
Provides information of the matchings associated to a program

> (get-match "HEP" (gale-shapely RLIST PLIST '()))
("HEP" ((913 . 2) (403 . 0)))
> (get-match "NRS" (gale-shapely RLIST PLIST '()))
("NRS" ((126 . 5) (517 . 1) (574 . 0)))
|#