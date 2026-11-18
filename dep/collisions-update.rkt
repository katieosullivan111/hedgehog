#lang racket
(require "header.rkt")
(require "AI.rkt")
(require racket/list)
(provide collisions-update interval)

;Checks if the car is touching an object
(define (touching? pos1 pos2)
  (let ([range-x 60] [range-y 90]
    [x1 (pos-x pos1)] [y1 (pos-y pos1)]
    [x2 (pos-x pos2)] [y2 (pos-y pos2)])
    (and (<= (abs (- x1 x2)) range-x) (<= (abs (- y1 y2)) range-y))))
            
;This function checks whether game-state objects like BOOST or EXTRALIFE are too far behind the player so that they can be recycled
(define (behind? p game)
  (< (pos-y (gs-player game)) (- (pos-y (p game)) 300)))

; This function splits the list of NPCS into three: whether they are within a reasonable distance of the player, whether we have passed them or whether they are too far in front. Add-gap then takes the list
; of cars which are too far behind, takes their pos and converts it to one in front and then it is appended back onto to the list of cars within a reasonable distance to the player
; Let-values allows the two lists to be distinguished and called within the function
(define (keep-cars? x game)
  (let*-values (
    [(a b) (partition
      (lambda (y) (< (pos-y (car-pos y)) (+ (pos-y (gs-player game)) 1000)))
      x)]
    [(c d) (partition
      (lambda (y) (< (pos-y (car-pos y)) (- (pos-y (gs-player game)) 2500)))
      a)])

    (append (add-gap b game -1) d (add-gap c game 1))))

;This function partitions the list into cars that are not touching and cars which are, so they can de identified and adjusted
(define (checker x game)
  (if (empty? x) 
    empty
    (let-values ([(i j) (partition
      (lambda (y)
        (and
          (<= (abs (- (pos-y (car-pos y)) (pos-y (car-pos (first x))))) 200)
          (<= (abs (- (pos-x (car-pos y)) (pos-x (car-pos (first x))))) 55)))
      (remove (first x) x))])

      (cons (first x) (append (add-small-gap i game) (checker j game))))))

;This gives cars which are touching a new pos away from each other
(define (add-small-gap x game)
  (if (empty? x)
      empty
      (cons (car (pos (pos-x (car-pos (first x))) (- (pos-y (car-pos (first x))) 100)) (car-speed (first x)) (car-index (first x))) (add-small-gap (rest x) game))))

; Gives cars which need to be recycled a new pos in front of the player
 (define (add-gap x game direction) ; direction -1 for in front, +1 for behind player
  (local [
    (define r (random ROAD.LANES))
    (define x-offset (random (- (round (/ ROAD.WIDTH ROAD.LANES)) 35)))]
    (if (empty? x)
      empty
      (cons
        (car (pos (+ (list-ref AI.LANEX r) x-offset) (+ (pos-y (gs-player game)) (* (+ (random 500) 1000) direction))) (m2p 35) (random AI.imagecount))
        (add-gap (rest x) game direction)))))

; How far ahead the collectibles spawn depending on velocity
(define (spawn-distance game)
  (cond
    [(< (pos-y (gs-velocity game)) 50) (+ (random 100) 1800)]
    [(< (pos-y (gs-velocity game)) 100) (+ (random 100) 2500)]
    [(< (pos-y (gs-velocity game)) 150) (+ (random 100) 3500)]
    [else (+ (random 100) 4500)]))

; Returns a random x value within the bounds of the road
(define (interval) (+ (random ROAD.WIDTH) (first AI.LANEX)))

;Collisions with cars and objects which affect the gs
(define (collisions-update game delta)
  (local [
    (define (update-cars cars game delta)
      (if (empty? cars)
        empty
        (let*
          ([npc (first cars)] [v-car (car-speed npc)]
          [x-car (pos-x (car-pos npc))] [y-car (pos-y (car-pos npc))]
          [x (pos-x (gs-player game))] [y (pos-y (gs-player game))])

          (cons
            (car
              (pos x-car (- y-car (* v-car delta))) ; Updated npc position
              ; Re-calculate npc speed if collides with player
              (if (and (<= (abs (- y y-car)) 110) (<= (abs (- x x-car)) 50))
                (let* ([vx (pos-x (gs-velocity game))] [vy (pos-y (gs-velocity game))]
                  [e*v-relative (* CAR.E (- vy v-car))] ; (Co-eff of Restituion)(Relative V)
                  [v-total (+ vy v-car)]) ; Sum of original car and player v

                  ; Applying Principle of Conservation of Momentum, Newton's Restitution dynamics, vy = 0.5(v-tot - e*v-r), v-car = 0.5(v-tot + e*v-r)
                  (set-gs-velocity! game (pos vx (/ (- v-total e*v-relative) 2)))

                  ; Rebound player horizontally
                  (set-gs-wheel! game (* (- x x-car) 0.5)) ; .5 dampening effect

                  (set-gs-lives! game (- (gs-lives game) 1))
                  (set-gs-player! game (pos x (+ y (* 10 (if (< vy v-car) -1 1)))))

                  ; Return value: NPC's speed
                  (/ (+ v-total e*v-relative) 2))
                v-car)
              (car-index npc))
            (update-cars (rest cars) game delta)))))
  ]
    (set-gs-cars! game (update-cars (keep-cars? (checker (gs-cars game) game) game) game delta))

    ; Handle Boost and Extra-time items
    (when (touching? (gs-BOOST game) (gs-player game))
      (set-gs-BOOST! game (pos (interval) (- (pos-y (gs-BOOST game)) (+ (random 1000) 2000))))
      (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (+ (pos-y (gs-velocity game)) 200))))
    (when (touching? (gs-EXTRALIFE game) (gs-player game))
      (set-gs-EXTRALIFE! game (pos (interval) (- (pos-y (gs-EXTRALIFE game)) (+ (random 5000) 10000))))
      (set-gs-deadline! game (+ (gs-deadline game) 2000)))

    ; Recyclyes items when out of bounds
    (when (behind? gs-BOOST game)
      (set-gs-BOOST! game (pos (interval) (- (pos-y (gs-BOOST game)) (spawn-distance game)))))
    (when (behind? gs-EXTRALIFE game)
      (set-gs-EXTRALIFE! game (pos (interval) (- (pos-y (gs-EXTRALIFE game)) (spawn-distance game)))))

    game))
