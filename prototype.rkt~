#lang racket
(provide (struct-out pos) (struct-out gs) (struct-out car) mega vroom-vroom cars  m2p p2m)

(struct pos (x y)) ; Position Structure
(struct gs (camera player velocity accelerator lives BOOST EXTRALIFE cars vehicles) #:mutable) ; Game State
(struct car (x y) #:mutable)
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters


;Creates a list of random cars
(define (sum car g)
      (if (<= g 50)
      (cons (car (+ (random 800) 100) (+ (random 800) 100)) (sum car (+ g 1)))
      empty))

;Creates 51 random cars
(define mega
  (sum car 0))


  

;Converts the cars to pos
(define (cars mega game)
  (if (empty? mega)
      empty
      (cons (pos (- (car-x (first mega)) (pos-x (gs-camera game))) (- (car-y (first mega))
                                                                             (pos-y (gs-camera game))))
            (cars (rest mega) game))))


;Allows us to take out some elements
(define (list-maker-cars x game)
  (take (cars mega game) x))


;Sets the gs to that list of pos for draw game
(define (vroom-vroom game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (list-maker-cars 5 game)]
    [(and (<= (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (list-maker-cars 10 game)]
    [(and (<= (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (list-maker-cars 15 game)]
    [else (list-maker-cars 20 game)]))
 