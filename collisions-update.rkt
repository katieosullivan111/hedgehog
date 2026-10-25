#lang racket
(require "prototype.rkt")
(require "animation.rkt")
(provide collisions-update)

(define (touching? p game)
  (<= (sqrt (+ (expt (- (pos-x (gs-player game)) (pos-x (p game))) 2)
                  (expt (- (pos-y (gs-player game)) (pos-y (p game))) 2))) 60))
 
;How far the player moves after a crash depending on velocity     
(define (crash-distance game)
  (cond
    [(< (pos-y (gs-velocity game)) 50) 75]
    [(and (> (pos-y (gs-velocity game)) 50) (< (pos-y (gs-velocity game)) 100) 125)]
    [(and (> (pos-y (gs-velocity game)) 100) (< (pos-y (gs-velocity game)) 150) 150)]
    [(> (pos-y (gs-velocity game)) 150) 200]))

;How far ahead the cars spawn depending on velocity
(define (spawn-distance game)
  (cond
    [(< (pos-y (gs-velocity game)) 50) (+ (random 250) 750)]
    [(and (> (pos-y (gs-velocity game)) 50) (< (pos-y (gs-velocity game)) 100)) (+ (random 250) 1000)]
    [(and (> (pos-y (gs-velocity game)) 100) (< (pos-y (gs-velocity game)) 150)) (+ (random 250) 1250)]
    [(> (pos-y (gs-velocity game)) 150) (+ (random 250) 1500)]))

(define (past? game p)
  (> (+ (pos-y (gs-player game)) (pos-y (p game)) 2000)))

(define (out-of-bounds-left p game)  
      (< (pos-x (p game)) 100))

(define (out-of-bounds-right p game)  
      (> (pos-x (p game)) 900))

(define (behind? p game)
  (< (- (pos-y (gs-player game)) (pos-y (p game))) -500))

(define (interval game)
  (+ (* (pos-x (gs-player game)) 0) (+ (random 900) 100)))
(define interval2 (random 150))

;Collisions with cars and objects which affect the gs
(define (collisions-update game)
  (when
    (or
        (touching? gs-truck1 game)
        (touching? gs-truck2 game)
        (touching? gs-truck3 game)
        (touching? gs-car1 game)
        (touching? gs-car2 game)
        (touching? gs-car3 game)
        (touching? gs-car4 game)
        (touching? gs-car5 game)
        (touching? gs-car6 game))
     (set-gs-lives! game (- (gs-lives game) 1)) (set-gs-player! game (pos (pos-x (gs-player game)) (+ (pos-y (gs-player game)) (crash-distance game)))))    
;Power-Ups
  (when
    (touching? gs-BOOST game)
     (and (set-gs-BOOST! game (pos (interval game) (- (pos-y (gs-BOOST game)) (+ (random 1000) 2000)))) (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (+ (pos-y (gs-velocity game)) 200)))))
 (when
     (touching? gs-EXTRALIFE game)
    (and (set-gs-EXTRALIFE! game (pos (interval game) (- (pos-y (gs-EXTRALIFE game)) (+ (random 1000) 20000)))) (set-gs-lives! game (+ (gs-lives game) 1))))
  (when
      (out-of-bounds-left gs-player game)
    (and (set-gs-lives! game (- (gs-lives game) 1)) (set-gs-player! game (pos (+ (pos-x (gs-player game)) 100) (pos-y (gs-player game))))))
  (when
      (out-of-bounds-right gs-player game)
      (and (set-gs-lives! game (- (gs-lives game) 1)) (set-gs-player! game (pos (- (pos-x (gs-player game)) 100) (pos-y (gs-player game))))))
  (when
      (out-of-bounds-left gs-BOOST game)
    (and (set-gs-BOOST! game (pos (interval game) (pos-y (gs-BOOST game))))))
  (when
      (out-of-bounds-right gs-BOOST game)
    (and (set-gs-BOOST! game (pos (interval game) (pos-y (gs-BOOST game))))))
  (when
      (out-of-bounds-left gs-EXTRALIFE game)
    (and (set-gs-EXTRALIFE! game (pos (interval game) (pos-y (gs-EXTRALIFE game))))))
  (when
      (out-of-bounds-right gs-EXTRALIFE game)
    (and (set-gs-EXTRALIFE! game (pos (interval game) (pos-y (gs-EXTRALIFE game))))))
;Recyclyes Vehicles and Objects
  (when
       (behind? gs-truck1 game)
    (set-gs-truck1! game (pos (interval game) (- (pos-y (gs-truck1 game)) (spawn-distance game))))) 
  (when
       (behind? gs-truck2 game)
    (set-gs-truck2! game (pos (interval game) (- (pos-y (gs-truck2 game)) (spawn-distance game)))))
  (when
       (behind? gs-truck3 game)
    (set-gs-truck3! game (pos (interval game) (- (pos-y (gs-truck3 game)) (spawn-distance game)))))
  (when
       (behind? gs-car1 game)
    (set-gs-car1! game (pos (interval game) (- (pos-y (gs-car1 game)) (spawn-distance game)))))
  (when
       (behind? gs-car2 game)
    (set-gs-car2! game (pos (interval game) (- (pos-y (gs-car2 game)) (spawn-distance game)))))
  (when
       (behind? gs-car3 game)
    (set-gs-car3! game (pos (interval game) (- (pos-y (gs-car3 game)) (spawn-distance game)))))
  (when
       (behind? gs-car4 game)
    (set-gs-car4! game (pos (interval game) (- (pos-y (gs-car4 game)) (spawn-distance game)))))
  (when
       (behind? gs-car5 game)
    (set-gs-car5! game (pos (interval game) (- (pos-y (gs-car5 game)) (spawn-distance game)))))
  (when
       (behind? gs-car6 game)
    (set-gs-car6! game (pos (interval game) (- (pos-y (gs-car6 game)) (spawn-distance game)))))
  (when
      (behind? gs-BOOST game)
    (set-gs-BOOST! game (pos (interval game) (- (pos-y (gs-BOOST game)) (spawn-distance game)))))
    (when
        (behind? gs-EXTRALIFE game)
      (set-gs-EXTRALIFE! game (pos (interval game) (- (pos-y (gs-BOOST game)) (spawn-distance game)))))
 ; Bounds Vechicles for Random Positioning
(when
      (out-of-bounds-left gs-truck1 game)
    (and (set-gs-truck1! game (pos (interval game) (pos-y (gs-truck1 game))))))
  (when
      (out-of-bounds-left gs-truck2 game)
    (and (set-gs-truck2! game (pos (interval game) (pos-y (gs-truck2 game))))))
  (when
      (out-of-bounds-left gs-truck3 game)
    (and (set-gs-truck3! game (pos (interval game) (pos-y (gs-truck3 game))))))
  (when
      (out-of-bounds-left gs-car1 game)
    (and (set-gs-car1! game (pos (interval game) (pos-y (gs-car1 game))))))
   (when
      (out-of-bounds-left gs-car2 game)
    (and (set-gs-car2! game (pos (interval game) (pos-y (gs-car2 game))))))
   (when
      (out-of-bounds-left gs-car3 game)
    (and (set-gs-car3! game (pos (interval game) (pos-y (gs-car3 game))))))
   (when
      (out-of-bounds-left gs-car4 game)
    (and (set-gs-car4! game (pos (interval game) (pos-y (gs-car4 game))))))
   (when
      (out-of-bounds-left gs-car5 game)
    (and (set-gs-car5! game (pos (interval game) (pos-y (gs-car5 game))))))
   (when
      (out-of-bounds-left gs-car6 game)
    (and (set-gs-car6! game (pos (interval game) (pos-y (gs-car6 game))))))
  (when
      (out-of-bounds-right gs-truck1 game)
    (and (set-gs-truck1! game (pos (interval game) (pos-y (gs-truck1 game))))))
  (when
      (out-of-bounds-right gs-truck2 game)
    (and (set-gs-truck2! game (pos (interval game) (pos-y (gs-truck2 game))))))
  (when
      (out-of-bounds-right gs-truck3 game)
    (and (set-gs-truck3! game (pos (interval game) (pos-y (gs-truck3 game))))))
  (when
      (out-of-bounds-right gs-car1 game)
    (and (set-gs-car1! game (pos (interval game) (pos-y (gs-car1 game))))))
   (when
      (out-of-bounds-right gs-car2 game)
    (and (set-gs-car2! game (pos (interval game) (pos-y (gs-car2 game))))))
   (when
      (out-of-bounds-right gs-car3 game)
    (and (set-gs-car3! game (pos (interval game) (pos-y (gs-car3 game))))))
   (when
      (out-of-bounds-right gs-car4 game)
    (and (set-gs-car4! game (pos (interval game) (pos-y (gs-car4 game))))))
   (when
      (out-of-bounds-right gs-car5 game)
    (and (set-gs-car5! game (pos (interval game) (pos-y (gs-car5 game))))))
   (when
      (out-of-bounds-right gs-car6 game)
    (and (set-gs-car6! game (pos (interval game) (pos-y (gs-car6 game))))))
  game)