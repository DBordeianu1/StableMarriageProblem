#lang scheme
#|
Project CSI2120/CSI2520
Winter 2026

Completed by Roman Solomakha St. No. 300422752 and Daniela Bordeianu St. No. 300435411
|#

(require "rpReader.scm")
(define PLIST (read-programs "programSmall.csv"))
(define RLIST (read-residents "residentSmall.csv"))

; Returns the list of programs for a resident
(define (resRol L) (cadddr L))

; Returns the list of the program
(define (programRol L) (cadddr L))

; define quota as well
(define (get-quota L) (caddr L))

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
Returns true if this resident has been matched to a program

These tests were provided by the Professor, but not useful if gale-shapley not implemented yet:
> (matched? 403 (gale-shapley RLIST PLIST '()))
#t
> (matched? 377 (gale-shapley RLIST PLIST '()))
#f

So here are some custom tests:
> (matched? 403 '(("OBG" ((773 . 2) (828 . 1) (616 . 0))) ("MMI" ((226 . 2))) ("HEP"
((913 . 2) (403 . 0))) ("NRS" ((126 . 5) (517 . 1) (574 . 0)))))
#t
> (matched? 377 '(("OBG" ((773 . 2) (828 . 1) (616 . 0))) ("MMI" ((226 . 2))) ("HEP"
((913 . 2) (403 . 0))) ("NRS" ((126 . 5) (517 . 1) (574 . 0)))))
#f
|#
; Helper
(define (res-in-pro? rid program-matches)
  (cond ((null? program-matches) #f)
        ((eq? rid (caar program-matches)) #t)
        (else (res-in-pro? rid (cdr program-matches)))
    )
  )

; Actual implementation
(define (matched? rid matches)
(cond ((null? matches) #f)
((res-in-pro? rid (cadar matches)) #t)
(else (matched? rid (cdr matches)))
  )
  )

#|
Provides information of the matchings associated to a program

These tests were provided by the Professor, but not useful if gale-shapley not implemented yet:
> (get-match "HEP" (gale-shapely RLIST PLIST '()))
("HEP" ((913 . 2) (403 . 0)))
> (get-match "NRS" (gale-shapely RLIST PLIST '()))
("NRS" ((126 . 5) (517 . 1) (574 . 0)))

So here are some custom tests:
> (get-match "HEP" '(("OBG" ((773 . 2) (828 . 1) (616 . 0))) ("MMI" ((226 . 2))) ("HEP" ((913 . 2) (403 . 0))) ("NRS" ((126 . 5) (517 . 1) (574 . 0)))))
("HEP" ((913 . 2) (403 . 0)))
> (get-match "NRS" '(("OBG" ((773 . 2) (828 . 1) (616 . 0))) ("MMI" ((226 . 2))) ("HEP" ((913 . 2) (403 . 0))) ("NRS" ((126 . 5) (517 . 1) (574 . 0)))))
("NRS" ((126 . 5) (517 . 1) (574 . 0)))
|#
(define (get-match pid matches)
(cond ((null? matches) (list pid))
((string=? pid (caar matches)) (car matches))
(else (get-match pid (cdr matches)))
)
  )

#|
Add a resident (+ its rank) to the list of residents matched to a program

Test provided by the Professor, but not useful if gale-shapley not implemented yet:
> (add-resident-to-match (cons 828 3)(get-match "NRS" (gale-shapely RLIST PLIST '())))
("NRS" ((126 . 5) (828 . 3) (517 . 1) (574 . 0)))

So here is a custom test:
> (add-resident-to-match (cons 828 3) '("NRS" ((126 . 5) (517 . 1) (574 . 0))))
("NRS" ((126 . 5) (828 . 3) (517 . 1) (574 . 0)))
|#
; Helper
(define (append-desc-rank pair match-no-car)
  (cond ((< (cdar match-no-car) (cdr pair)) (cons pair match-no-car))
        (else (cons (car match-no-car) (append-desc-rank pair (cdr match-no-car))))
    )
  )

; Actual implementation
(define (add-resident-to-match pair match)
  (cond ((null? match) '())
        ((null? (cdr match)) (list (car match) (list pair)))
        (else (list (car match)(append-desc-rank pair (cadr match))))
    )
  )

#|
In order to implement the McVitie-Wilson algorithm, we will need to implement offer

> (offer (car RLIST) RLIST PLIST '())
(("NRS" ((574 . 0))))
> (offer (cadr RLIST) RLIST PLIST
(offer (car RLIST) RLIST PLIST '()))
(("NRS" ((517 . 1) (574 . 0))))
> (offer (caddr RLIST) RLIST PLIST
(offer (cadr RLIST) RLIST PLIST
(offer (car RLIST) RLIST PLIST '())))
(("HEP" ((403 . 0))) ("NRS" ((517 . 1) (574 . 0))))
|#
(define (offer rinfo rlist plist matches)
  (cond ((null? (resRol rinfo)) matches)
        (else (evaluate rinfo (get-program-info (car (resRol rinfo)) plist) rlist plist matches))
    )
  )

#|
In order to implement the McVitie-Wilson algorithm, we will need to implement evaluate as well

> (define M1 (offer (caddr RLIST) RLIST PLIST
(offer (cadr RLIST) RLIST PLIST
(offer (car RLIST) RLIST PLIST '()))))
> (define M2 (evaluate (get-resident-info 226 RLIST)
(get-program-info "HEP" PLIST) RLIST PLIST M1))
> M2
(("HEP" ((226 . 4) (403 . 0))) ("NRS" ((517 . 1) (574 . 0))))
> (evaluate (get-resident-info 913 RLIST) (get-program-info "HEP"
PLIST) RLIST PLIST M2)
(("MMI" ((226 . 2))) ("HEP" ((913 . 2) (403 . 0)))("NRS" ((517 . 1) (574 . 0))))
|#
; Helper for update-match to check if program is in the current matches
(define (in-matches? pid matches)
  (cond ((null? matches) #f)
        ((string=? pid (caar matches)) #t)
        (else (in-matches? pid (cdr matches)))
    )
  )

; Helper for evaluate to append the nonexistent program, if applicable, at the front or
; to modify it directly (i.e. keeping order)
(define (update-match updated-entry matches)
  (if (in-matches? (car updated-entry) matches)
  (cond ((string=? (car updated-entry) (caar matches))
                (cons updated-entry (cdr matches)))
        (else (cons (car matches) (update-match updated-entry (cdr matches))))
   )
  (cons updated-entry matches)
  )
  )

; To get the least preferred resident from the programs' current matches
; L is a list of this type: ("NRS" ((126 . 5) (517 . 1) (574 . 0)))
(define (least-preferred L) (caadr L))

; Actual implementation of evaluate
(define (evaluate rinfo pinfo rlist plist matches)
  (cond ((= (rank (resID rinfo) pinfo) -1) matches)

    ((null? (cdr (get-match (programID pinfo) matches)))
              (update-match (add-resident-to-match (cons (resID rinfo) (rank (resID rinfo) pinfo)) (get-match (programID pinfo) matches)) matches)
              )
    
    ((> (get-quota pinfo) (length (cadr (get-match (programID pinfo) matches))))
           (update-match (add-resident-to-match (cons (resID rinfo) (rank (resID rinfo) pinfo)) (get-match (programID pinfo) matches)) matches))
    
    ((> (cdr (least-preferred (get-match (programID pinfo) matches))) (rank (resID rinfo) pinfo))
            (let* ((r-prime (car (least-preferred (get-match(programID pinfo) matches))))
                   (entry-without-r-prime (list (programID pinfo) (cdadr (get-match (programID pinfo) matches))))
                   (entry-with-r (add-resident-to-match (cons (resID rinfo) (rank (resID rinfo) pinfo)) entry-without-r-prime))
                   (updated-matches (update-match entry-with-r matches)))
              (offer (get-resident-info r-prime rlist) rlist plist updated-matches)))
    
    (else matches)
            )
    )

#|
|#
(define (gale-shapley rlist plist matches)
  (cond ((null? rlist) matches)
  (else (gale-shapley (cdr rlist) plist (offer (car rlist) rlist plist matches)))
  ))

#|
|#
(define (get-not-matched-list rlist matches)
  (cond ((null? rlist) '())
        ((not (matched? (resID (car rlist)) matches))
         (cons (car rlist) (get-not-matched-list (cdr rlist) matches)))
        (else (get-not-matched-list (cdr rlist) matches))
        )
  )

#|
|#
(define (display-not-matched not-matched-list rlist)
  (for-each (lambda(m)
  (display (cadr(get-resident-info (car m) rlist)))
  (display ",")
  (display (caddr(get-resident-info (car m) rlist)))
  (display ",")
  (display (car m))
  (display ",")
  (display "XXX,NOT_MATCHED")
  (newline))
  (not-matched-list))
  )

#|
|#
(define (display-program-matches pmatches rlist plist)
  (for-each (lambda(m)
  (display (cadr(get-resident-info (car m) rlist)))
  (display ",")
  (display (caddr(get-resident-info (car m) rlist)))
  (display ",")
  (display (car m))
  (display ",")
  (display (car pmatches))
  (display ",")
  (display (cadr(get-program-info (car pmatches) plist)))
  (newline))
  (cdr pmatches))
  )

#|
|#
(define (get-total-available-positions matches plist)
  (let ((count 0)) '())
  (for-each (lambda(m)
  (+ count (-(caddr(get-program-info (car m) plist))(length (cdr m)))))
  (cdr matches))
  count
  )

#|
|#
(define (gale-shapley-print rlist plist)
  (let* ((matches (gale-shapley rlist plist '()))
         (not-matched-list (get-not-matched-list rlist matches)))
    (for-each (lambda(m)
         (display-program-matches m rlist plist)) matches)
    (display-not-matched not-matched-list rlist)
    (display "Number of unmatched residents: ")
    (display (length not-matched-list)) (newline)
    (display "Number of positions available: ")
    (display (get-total-available-positions matches plist))
    (newline))
  )