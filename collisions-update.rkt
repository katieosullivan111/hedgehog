#lang racket
(require "prototype.rkt")
(require "animation.rkt")
(require "NPC-MOVEMENT.rkt")
(provide collisions-update mega cars give-velocity vroom-vroom)

(define (touching? p game)
  (<= (sqrt (+ (expt (- (pos-x (gs-player game)) (pos-x (p game))) 2)
                  (expt (- (pos-y (gs-player game)) (pos-y (p game))) 2))) 60))


(define (touching-cars? x game)
  (if (empty? x)
      #false
 (if (<= (sqrt (+ (expt (- (pos-x (gs-player game)) (pos-x (first x))) 2)
                  (expt (- (pos-y (gs-player game)) (pos-y (first x))) 2))) 60)
     #true
     (touching-cars? (rest x) game))))
    

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
    [(< (pos-y (gs-velocity game)) 50) (+ (random 100) 350)]
    [(and (> (pos-y (gs-velocity game)) 50) (< (pos-y (gs-velocity game)) 100)) (+ (random 100) 500)]
    [(and (> (pos-y (gs-velocity game)) 100) (< (pos-y (gs-velocity game)) 150)) (+ (random 100) 750)]
    [(> (pos-y (gs-velocity game)) 150) (+ (random 100) 1000)]))

(define (past? game p)
  (> (+ (pos-y (gs-player game)) (pos-y (p game)) 2000)))

(define (out-of-bounds-left p game)  
      (< (pos-x (p game)) 100))

(define (out-of-bounds-right p game)  
      (> (pos-x (p game)) 900))

(define (out-of-bounds p game)
  (or (< (pos-x (p game)) 100)
      (> (pos-x (p game)) 900)))

(define (behind? p game)
  (< (- (pos-y (gs-player game)) (pos-y (p game))) -500))

(define (behind-cars? x game)
  (if (empty? x)
      #false
      (if (< (- (pos-y (gs-player game)) (car-y (first x))) -500)
        (and (set-car-y! (first x) (- (car-y (first x)) (spawn-distance game)))
             (set-car-x! (first x) (interval game)) (behind-cars? (rest x) game))
          (behind-cars? (rest x) game))))

;Returns a pos which a random pos is built on for cars and items
(define (interval game)
  (+ (* (pos-x (gs-player game)) 0) (+ (random 800) 100)))


;Collisions with cars and objects which affect the gs
(define (collisions-update game)
  ;Controls collisions with other cars
  ;(when
      ;(touching-cars? (gs-cars game) game)
    ;(set-gs-lives! game (- (gs-lives game) 1)) (set-gs-player! game (- (pos-y (gs-player game)) (spawn-distance game))))
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
;Recyclyes Vehicles and Objects
       
  (when
      (behind? gs-BOOST game)
    (set-gs-BOOST! game (pos (interval game) (- (pos-y (gs-BOOST game)) (spawn-distance game)))))
  (if
    (>= (gs-lives game) 5)
    (set-gs-EXTRALIFE! game (pos 10000 (pos-y (gs-EXTRALIFE game))))
    (set-gs-EXTRALIFE! game (pos (pos-x (gs-EXTRALIFE game)) (pos-y (gs-EXTRALIFE game)))))
    (when
        (behind? gs-EXTRALIFE game)
      (set-gs-EXTRALIFE! game (pos (interval game) (- (pos-y (gs-EXTRALIFE game)) (spawn-distance game)))))
(behind-cars? mega game)
  game)
