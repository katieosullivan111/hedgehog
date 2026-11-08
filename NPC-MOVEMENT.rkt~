#lang racket
(require "prototype.rkt")
(provide give-velocity)

(define (NPC-MOVEMENT x game)
    (if (empty? x)
        empty
(and (set-car-x!  (first x) (car-x (first x))) (set-car-y! (first x) (- (car-y (first x)) (speed game)))
    (NPC-MOVEMENT (rest x) game))))

;Gives NPCS velocity
(define (give-velocity game)
  (NPC-MOVEMENT mega game))
 

  (define (speed game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (+ (random 5) 1)]
    [(and (< (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (+ (random 5) 3)]
    [(and (< (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (+ (random 5) 5)]
    [(and (< (pos-y (gs-player game)) -3000) (> (pos-y (gs-player game)) -4000)) (+ (random 5) 7)]
    [(and (< (pos-y (gs-player game)) -4000) (> (pos-y (gs-player game)) -5000)) (+ (random 5) 9)]
    [(and (< (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -6000)) (+ (random 5) 10)]
    [(and (< (pos-y (gs-player game)) -6000) (> (pos-y (gs-player game)) -7000)) (+ (random 5) 12)]
    [(and (< (pos-y (gs-player game)) -7000) (> (pos-y (gs-player game)) -8000)) (+ (random 5) 15)]
    [(and (< (pos-y (gs-player game)) -8000) (> (pos-y (gs-player game)) -9000)) (+ (random 5) 17)]
    [(< (pos-y (gs-player game)) -9000) (+ (random 5) 20)]))







  