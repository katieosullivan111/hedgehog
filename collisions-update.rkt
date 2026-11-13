#lang racket
(require "prototype.rkt")
(require "NPC-MOVEMENT.rkt")
(require "animation.rkt")
(require racket/list)
(provide collisions-update)

;Checks if the car is touching an object
(define (touching? p game)
  (<= (sqrt (+ (expt (- (pos-x (gs-player game)) (pos-x (p game))) 2)
                  (expt (- (pos-y (gs-player game)) (pos-y (p game))) 2))) 60))

;Checks whether car is touching any npcs
(define (touching-cars? x game)
  (if (empty? x)
      #false
      (if (and (<= (abs (- (pos-y (gs-player game)) (pos-y (car-pos (first x))))) 110) (<= (abs (- (pos-x (gs-player game)) (pos-x (car-pos (first x))))) 55))
                (and (set-gs-lives! game (- (gs-lives game) 1)) (set-gs-player! game (pos (pos-x (gs-player game)) (+ (pos-y (gs-player game)) (crash-distance game))))
                     (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (* (pos-y (gs-velocity game)) 0.7))))
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
    [(< (pos-y (gs-velocity game)) 50) (+ (random 100) 1800)]
    [(and (> (pos-y (gs-velocity game)) 50) (< (pos-y (gs-velocity game)) 100)) (+ (random 100) 2500)]
    [(and (> (pos-y (gs-velocity game)) 100) (< (pos-y (gs-velocity game)) 150)) (+ (random 100) 3500)]
    [(> (pos-y (gs-velocity game)) 150) (+ (random 100) 4500)]))

;This function checks whether the player is in bounds on the leftmost lane
(define (out-of-bounds game)  
       (if (< (pos-x (gs-player game)) 200)
            (and (set-gs-lives! game (- (gs-lives game) 1)) (set-gs-player! game (pos (+ (pos-x (gs-player game)) 100) (pos-y (gs-player game))))
                 (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (* (pos-y (gs-velocity game)) 0.7))))
            (if (> (pos-x (gs-player game)) 800)
            (and (set-gs-lives! game (- (gs-lives game) 1)) (set-gs-player! game (pos (- (pos-x (gs-player game)) 100) (pos-y (gs-player game))))
                 (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (* (pos-y (gs-velocity game)) 0.7))))
  game)))
            


;This function checks whether the player is in bounds on the rightmost lane
(define (out-of-bounds-right p game)  
      (> (pos-x (p game)) 900))

;This function checks whether game-state objects like BOOST or EXTRALIFE are too far behind the player so that they can be recycled
(define (behind? p game)
  (< (- (pos-y (gs-player game)) (pos-y (p game))) -500))

;This function splits the list of NPCS into threeo: whether they are within a reasonable distance of the player, whether we have passed them or whether they are too far in front. Add-gap then takes the list
;of cars which are too far behind, takes their pos and converts it to one in front and then it is appended back onto to the list of cars within a reasonable distance to the player
;Let-values allows the two lists to be distinguished and called within the function
(define (keep-cars? x game)
  (let-values ([(a b) (partition (lambda (y) (< (pos-y (car-pos y)) (+ (pos-y (gs-player game))
                 2500))) x)])
    (let-values ([(c d) (partition (lambda (y) (< (pos-y (car-pos y)) (- (pos-y (gs-player game))
                 2500))) a)])
    (append (add-gap b game) d (take-gap c game)))))
  

(define (clashing? x game)
  (let-values ([(g h) (partition (lambda (y) (and (<= (abs (- (pos-y (car-pos y)) (pos-y (car-pos y)))) 110)
                                                    (<= (abs (- (pos-x (car-pos y)) (pos-x (car-pos y)))) 55))) x)])
    (append (add-small-gap g game) h)))

(define (clash-check y game)
  (if (empty? y)
      empty
      (if (and (<= (abs (- (pos-y (car-pos y)) (pos-y (car-pos y)))) 110)
                                                    (<= (abs (- (pos-x (car-pos y)) (pos-x (car-pos y)))) 55))
          (cons (add-small-gap y game) (clash-check (rest y) game))
          (empty))))

        
(define car-respawner
  (+ (random 1000) 3000))

(define (add-small-gap x game)
      (cons (car (pos (pos-x (car-pos x)) (- (pos-y (car-pos x)) 500)) (car-image x))))

;Gives cars which need to be recycled a new pos in front of the player
 (define (add-gap x game)
   (local
     [(define plus-or-minus (if (even? (list-ref q (random ll)))
   (random 100)
   (- (random 100))))]
   (if (empty? x)
       empty
       (cons (car (pos (+ (pos-x (list-ref lane (random 4))) plus-or-minus) (- (pos-y (car-pos (first x))) car-respawner)) (list-ref vehicles (random 11))) (add-gap (rest x) game)))))

(define (take-gap x game)
(local  
[(define plus-or-minus (if (even? (list-ref q (random ll)))
   (random 100)
   (- (random 100))))]
   (if (empty? x)
       empty
       (cons (car (pos (+ (pos-x (list-ref lane (random 4))) plus-or-minus) (+ (pos-y (car-pos (first x))) car-respawner)) (list-ref vehicles (random 11))) (take-gap (rest x) game)))))

;Returns a pos-x which a random pos is built on for cars and items
(define (interval game)
   (+ (random 700) 200))

;Collisions with cars and objects which affect the gs
(define (collisions-update game)
  ;Sets the cars game-state to a new list which checks whether cars which have velocity are behind, essentially keeping track of updated positions so that it can be passed to collisions
 (set-gs-cars! game (keep-cars? (give-velocity (gs-cars game) game) game))
  ;Controls collisions with other cars
 (touching-cars? (currentclasher game) game)
  ;Adds velocity when a player hits a boost
  (when
    (touching? gs-BOOST game)
     (and (set-gs-BOOST! game (pos (interval game) (- (pos-y (gs-BOOST game)) (+ (random 1000) 2000)))) (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (+ (pos-y (gs-velocity game)) 200)))))
  ;Adds an extra life to the gs when the player hits an extra life
 (when
     (touching? gs-EXTRALIFE game)
    (and (set-gs-EXTRALIFE! game (pos (interval game) (- (pos-y (gs-EXTRALIFE game)) (+ (random 1000) 10000)))) (set-gs-lives! game (+ (gs-lives game) 1))))
  ;Keeps the player inside the leftmost lane and rightmost lane and deducts a life for crossing them
 (out-of-bounds game)
;Recyclyes BOOST when the player has gone past it
  (when
      (behind? gs-BOOST game)
    (set-gs-BOOST! game (pos (interval game) (- (pos-y (gs-BOOST game)) (spawn-distance game)))))
  ;Ensures that an EXTRA-LIFE can not be obtained when the player already has 5 lives by transporting out of bounds
  (if
    (>= (gs-lives game) 5)
    (set-gs-EXTRALIFE! game (pos 10000 (pos-y (gs-EXTRALIFE game))))
    (set-gs-EXTRALIFE! game (pos (pos-x (gs-EXTRALIFE game)) (pos-y (gs-EXTRALIFE game)))))
  ;Recyclyes EXTRALIFE when the player has gone past it
    (when
        (behind? gs-EXTRALIFE game)
      (set-gs-EXTRALIFE! game (pos (interval game) (- (pos-y (gs-EXTRALIFE game)) (spawn-distance game)))))
  game)
