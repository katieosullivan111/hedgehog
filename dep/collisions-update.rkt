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

; This function adjusts cars which are too close together, by speeding up cars being overtaken
(define (ai-collisions c game)
  (letrec (
    [aux-func (lambda (npc c)
      (cond
        [(empty? c) empty]
        [(and
          (= (car-lane npc) (car-lane (first c))) ; Same Lane
          (>= (pos-y (car-pos npc)) (pos-y (car-pos (first c))))) ; npc lower than (first c)
          (<= (abs (- (pos-y (car-pos npc)) (pos-y (car-pos (first c))))) 150) ; Close y-positions
          
          (cons
            (car
              (pos (pos-x (car-pos (first c))) (- (pos-y (car-pos (first c))) 2))
              (+ (car-speed (first c)) 200) ; Speed up car to get it ahead
              (car-lane (first c))
              (car-index (first c)))
            (rest c))]
        [else (cons (first c) (aux-func npc (rest c)))]))])
    (if (empty? c)
      empty
      (cons (first c) (ai-collisions (aux-func (first c) (rest c)) game)))))

; Returns a random x value within the bounds of the road
(define (interval) (+ (random ROAD.WIDTH) (first AI.LANEX)))

;Collisions with cars and objects which affect the gs
(define (collisions-update game delta)
  (letrec (
    ; Constants
    [r (gs-player game)]
    [v (gs-velocity game)]

    [spawn-distance (lambda (v) ; How far ahead the collectibles spawn depending on velocity
      (cond
        [(< v 50) (+ (random 100) 1800)]
        [(< v 100) (+ (random 100) 2500)]
        [(< v 150) (+ (random 100) 3500)]
        [else (+ (random 100) 4500)]))]
    [normalise-v (lambda (v target)
      (min
        target
        (- v (* AI.deceleration delta))))]
    [recycle (lambda (c direction player-y player-v)
      (local [
        (define lane (random ROAD.LANES))
        (define x-offset (+ 35 (random (- (round (/ ROAD.WIDTH ROAD.LANES)) 70))))]
        (car
          (pos
            (+ (list-ref AI.LANEX lane) x-offset)
            (+ player-y (random 500) (* (+ SCENE.HEIGHT (if (< direction 0) player-v 0)) direction)))
          (hash-ref AI.LANESPEEDS lane)
          lane
          (random AI.imagecount))))]

    [update-cars (lambda (cars game delta)
      (if (empty? cars)
        empty
        (let*
          ([npc (first cars)] [v-car (car-speed npc)]
          [x-car (pos-x (car-pos npc))] [y-car (pos-y (car-pos npc))]
          [x (pos-x r)] [y (pos-y r)])

          (cons
            (cond
              ; Recycle cars that are far behind when the player is faster, or far ahead when slower.
              [(and
                (> (pos-y v) v-car)
                (> y-car (+ y 300))) ; Car too far behind
                (recycle npc -1 y (pos-y v))]
              [(and
                (< (pos-y v) v-car)
                (< y-car (- y SCENE.HEIGHT))) ; Car too far ahead
                (recycle npc 1 y (pos-y v))]
              ; Otherwise update npc normally
              [else (car
                (pos x-car (- y-car (* v-car delta))) ; Updated npc position

                ; Check for collision with player
                (if (and (<= (abs (- y y-car)) 110) (<= (abs (- x x-car)) 50))
                  (let* ([vx (pos-x v)] [vy (pos-y v)]
                    [e*v-relative (* CAR.E (- vy v-car))] ; (Co-eff of Restituion)(Relative V)
                    [v-total (+ vy v-car)]) ; Sum of original car and player v

                    ; Applying Principle of Conservation of Momentum, Newton's Restitution dynamics, vy = 0.5(v-tot - e*v-r), v-car = 0.5(v-tot + e*v-r)
                    (set-gs-velocity! game (pos vx (/ (- v-total e*v-relative) 2)))

                    ; Rebound player horizontally
                    (set-gs-wheel! game (* (- x x-car) 0.5)) ; .5 dampening effect

                    (set-gs-lives! game (- (gs-lives game) 1))
                    (set-gs-player! game (pos x (+ y (* 10 (if (< vy v-car) -1 1)))))
                    (crash)

                    ; Return value: NPC's speed
                    (/ (+ v-total e*v-relative) 2))
                  (normalise-v v-car (hash-ref AI.LANESPEEDS (car-lane npc))))
                (car-lane npc)
                (car-index npc))])
            (update-cars (rest cars) game delta)))))]
  )
    (set-gs-cars! game (update-cars (ai-collisions (reverse (gs-cars game)) game) game delta))

    ; Handle Boost and Extra-time items
    (when (touching? (gs-BOOST game) r)
      (set-gs-BOOST! game (pos (interval) (- (pos-y (gs-BOOST game)) (+ (random 1000) 2000))))
      (BOOST)
      (set-gs-velocity! game (pos (pos-x v) (+ (pos-y v) 200))))
    (when (touching? (gs-EXTRATIME game) r)
      (set-gs-EXTRATIME! game (pos (interval) (- (pos-y (gs-EXTRATIME game)) (+ (random 5000) 10000))))
      (EXTRATIME)
      (set-gs-deadline! game (+ (gs-deadline game) 2000)))

    ; Recyclyes items when out of bounds
    (when (behind? gs-BOOST game)
      (set-gs-BOOST! game (pos (interval) (- (pos-y (gs-BOOST game)) (spawn-distance (pos-y v))))))
    (when (behind? gs-EXTRATIME game)
      (set-gs-EXTRATIME! game (pos (interval) (- (pos-y (gs-EXTRATIME game)) (spawn-distance (pos-y v))))))

    game))
