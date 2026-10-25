#lang racket
(require "prototype.rkt")
(provide NPC-MOVEMENT)

;Gives NPCS velocity
(define (NPC-MOVEMENT game)
  (set-gs-truck1! game (pos (pos-x (gs-truck1 game)) (- (pos-y (gs-truck1 game)) (speed1 game))))                                           
  (set-gs-truck2! game (pos (pos-x (gs-truck2 game)) (- (pos-y (gs-truck2 game)) (speed2 game))))
  (set-gs-truck3! game (pos (pos-x (gs-truck3 game)) (- (pos-y (gs-truck3 game)) (speed3 game))))
(set-gs-car1! game (pos (pos-x (gs-car1 game)) (- (pos-y (gs-car1 game)) (speed3 game))))
  (set-gs-car2! game (pos (pos-x (gs-car2 game)) (- (pos-y (gs-car2 game)) (speed4 game))))
  (set-gs-car3! game (pos (pos-x (gs-car3 game)) (- (pos-y (gs-car3 game)) (speed3 game))))
   (set-gs-car4! game (pos (pos-x (gs-car4 game)) (- (pos-y (gs-car4 game)) (speed2 game))))
   (set-gs-car5! game (pos (pos-x (gs-car5 game)) (- (pos-y (gs-car5 game)) (speed1 game))))
   (set-gs-car6! game (pos (pos-x (gs-car6 game)) (- (pos-y (gs-car6 game)) (speed2 game))))
  game)



  (define (speed1 game)
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


(define (speed2 game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (random 5)]
    [(and (< (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000))(+ (random 5) 4)]
    [(and (< (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (+ (random 5) 5)]
    [(and (< (pos-y (gs-player game)) -3000) (> (pos-y (gs-player game)) -4000)) (+ (random 5) 7)]
    [(and (< (pos-y (gs-player game)) -4000) (> (pos-y (gs-player game)) -5000)) (+ (random 5) 8)]
    [(and (< (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -6000)) (+ (random 5) 11)]
    [(and (< (pos-y (gs-player game)) -6000) (> (pos-y (gs-player game)) -7000)) (+ (random 5) 13)]
    [(and (< (pos-y (gs-player game)) -7000) (> (pos-y (gs-player game)) -8000)) (+ (random 5) 14)]
    [(and (< (pos-y (gs-player game)) -8000) (> (pos-y (gs-player game)) -9000)) (+ (random 5) 18)]
    [(< (pos-y (gs-player game)) -9000) (+ (random 5) 21)]))


    

(define (speed3 game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (+ (random 5) 2)]
    [(and (< (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (+ (random 5) 6)]
    [(and (< (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (+ (random 5) 9)]
    [(and (< (pos-y (gs-player game)) -3000) (> (pos-y (gs-player game)) -4000)) (+ (random 5) 13)]
    [(and (< (pos-y (gs-player game)) -4000) (> (pos-y (gs-player game)) -5000)) (+ (random 5) 15)]
    [(and (< (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -6000)) (+ (random 5) 21)]
    [(and (< (pos-y (gs-player game)) -6000) (> (pos-y (gs-player game)) -7000)) (+ (random 5) 23)]
    [ (< (pos-y (gs-player game)) -7000)  (+ (random 5) 25)]))
 



(define (speed4 game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (random 5)]
    [(and (< (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (+ (random 5) 2)]
   [(and (< (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (+ (random 5) 4)]
    [(and (< (pos-y (gs-player game)) -3000) (> (pos-y (gs-player game)) -4000)) (+ (random 5) 6)]
    [(and (< (pos-y (gs-player game)) -4000) (> (pos-y (gs-player game)) -5000)) (+ (random 5) 8)]
    [(and (< (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -6000)) (+ (random 5) 9)]
    [(and (< (pos-y (gs-player game)) -6000) (> (pos-y (gs-player game)) -7000)) (+ (random 5) 14)]
    [(and (< (pos-y (gs-player game)) -7000) (> (pos-y (gs-player game)) -8000)) (+ (random 5) 17)]
    [(and (< (pos-y (gs-player game)) -8000) (> (pos-y (gs-player game)) -9000)) (+ (random 5) 18)]
    [(< (pos-y (gs-player game)) -9000) (+ (random 5) 20)]))




  