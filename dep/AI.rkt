; Car images from https://publicdomainvectors.org

#lang racket
(require "header.rkt")
(require 2htdp/image)
(provide give-velocity mega mega2 AI.cars AI.images AI.imagecount cars AI.LANEX)

;List of all vehicles
(define AI.imagecount 12)
(define AI.images (build-list AI.imagecount (lambda (i)
  (bitmap/file (string-append "img/npc/" (number->string (+ i 1)) ".png")))))

; Creates the intial lane positions on which all NPCS are placed relative to
(define AI.npc-height -200)
(define AI.LANEX
  (for/list ([i ROAD.LANES])
    (+ SCENE.HALFWIDTH (/ ROAD.WIDTH -2) (* i (/ ROAD.WIDTH ROAD.LANES)))))

;This function takes the list of NPCS and changes their positions to have constant velocity, which is proportional to the player's distance/score
(define (give-velocity x game delta)
  (if (empty? x)
      empty
      (cons (car (pos (pos-x (car-pos (first x)))
        (- (pos-y (car-pos (first x))) (speed game delta))) (car-index (first x)))
        (give-velocity (rest x) game delta))))

(define (speed game delta)
  (* delta (pos-y (gs-velocity game)) 0.8))

;Creates a list of random positions
;Uses an accumulator n to decide how many positions should be made
;a b c d ensure that no cars are initially placed on top of each other and place the next car a random position further than the last car,
;although an additional function is required to ensure the random positions dont overlap
;List ref will take the random number from rand-generator and run it in cond, so a random lane is selected without replacing constantly at a new lane.
(define (sum n lane-count)
  (if (< n AI.count)
    (local [
      (define q 800)
      (define y-offset (map (lambda (i) (* i q)) lane-count))
      (define randy (random 800)) (define r (random ROAD.LANES))
      (define x-offset (random (- (round (/ ROAD.WIDTH ROAD.LANES)) 35)))
      ]
      (cons
        (pos (+ (list-ref AI.LANEX r) x-offset) (- (list-ref y-offset r) randy))
        (sum (+ n 1) (list-increment lane-count r))))
    empty))


; Makes a list of 30 images to match the positions
; When the list is empty it appends the full list, until the total length is 81
(define (make-more-vehicles x g)
  (if (< g AI.count)
    (cons (list-ref AI.images (random AI.imagecount)) (make-more-vehicles x (+ g 1)))
    empty))

;Creates a list of AI.count random positions
(define mega
  (sum 0 (make-list ROAD.LANES 0)))

;Creates a list of AI.count vehicles
(define mega2 (make-more-vehicles AI.images 0))

; Converts the lists of random positions and images to random car structs
(define (car-maker x y n)
  (if (< n AI.count)
    (cons (car (first x) (first y)) (car-maker (rest x) (rest y) (+ n 1)))
    empty))

; Converts the lane positions to a pos relative to the camera to be placed in draw
(define (cars x game)
  (let (
    [xcam (pos-x (gs-camera game))]
    [ycam (pos-y (gs-camera game))])
  (if (empty? x)
    empty
    (cons
      (pos (- (pos-x (first x)) xcam)
        (- (pos-y (first x)) ycam))
      (cars (rest x) game)))))

; Makes the list of car struct which is passed to the initial gs-cars
(define AI.cars (car-maker mega mega2 0))
