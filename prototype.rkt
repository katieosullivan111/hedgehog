#lang racket
(provide (struct-out pos) (struct-out gs) mega lane vroom-vroom cars  m2p p2m)

(struct pos (x y)) ; Position Structure
(struct gs (camera player velocity accelerator lives BOOST EXTRALIFE cars) #:mutable #:transparent) ; Game State
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters

(define lw (random 150)) ; lane width


(define lane
  (list (pos (+ lw 150) 300)
       (pos (+ lw 350) 300)
       (pos (+ lw 500) 300) 
       (pos (+ lw 650) 300)))

(define (gap game)
    (cond
    [(> (pos-y (gs-player game)) -2000) (rand 900)]
    [(and (< (pos-y (gs-player game)) 50) (> (pos-y (gs-player game)) 100)) (rand 600)]
    [(and (< (pos-y (gs-player game)) 100) (> (pos-y (gs-player game)) 150)) (rand 150)]
    [else  200]))

(define (rand-gap-generator g)
  (if (<= g 1000)
      (cons
       (random 900) (rand-gap-generator (+ g 1)))
      empty))

(define (rand x)
  (+ 150 (random x)))

(define (rand-generator g)
  (if (<= g 150)
      (cons (random 4) (rand-generator (+ g 1)))
      empty))

(define q (rand-generator 0))

(define t (rand-gap-generator 0))
      ;Creates a list of random cars
(define (sum n a b c d game)
  (if (<= n 150)
      (local [(define e (* a 400)) (define f (* b 400)) (define g (* c 400)) (define h (* d 400))]
          (cons
      (cond
        [(= (list-ref q n) 0) (pos (pos-x (first (gs-cars game))) (- (pos-y (first (gs-cars game))) (+ e (list-ref t n))))]
        [(= (list-ref q n) 1) (pos (pos-x (second (gs-cars game))) (- (pos-y (second (gs-cars game))) (+ f (list-ref t n))))]
        [(= (list-ref q n) 2) (pos (pos-x (third (gs-cars game))) (- (pos-y (third (gs-cars game))) (+ g (list-ref t n))))]
        [else (pos (pos-x (fourth (gs-cars game))) (- (pos-y (fourth (gs-cars game))) (+ h (list-ref t n))))])
        (cond
        [(= (list-ref q n) 0) (sum (+ n 1) (+ a 1) b c d game)]
        [(= (list-ref q n) 1) (sum (+ n 1) a (+ b 1) c d game)]
        [(= (list-ref q n) 2) (sum (+ n 1) a b (+ c 1) d game)]
        [else (sum (+ n 1) a b c (+ d 1) game)])))
      empty))


;Creates 51 random cars
(define (mega game)
  (sum 0 0 0 0 0 game))

;Converts the cars to pos
(define (cars x game)
  (if (empty? x)
      empty
      (cons (pos (- (pos-x (first x)) (pos-x (gs-camera game))) (- (pos-y (first x))
                                                                             (pos-y (gs-camera game))))
            (cars (rest x) game))))

 

;Allows us to take out some elements
(define (list-maker-cars x game)
  (take (cars (mega game) game) x))


;Sets the gs to that list of pos for draw game
(define (vroom-vroom game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (list-maker-cars 20 game)]
    [(and (<= (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (list-maker-cars 40 game)]
    [(and (<= (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (list-maker-cars 60 game)]
    [else (list-maker-cars 80 game)]))
 