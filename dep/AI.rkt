; Car images from https://publicdomainvectors.org

#lang racket
(require "header.rkt")
(require 2htdp/image)
(provide mega mega2 AI.cars AI.images AI.imagecount cars AI.LANEX)

;List of all vehicles
(define AI.imagecount 12)
(define AI.images (make-hash))
(for/list ([i AI.imagecount])
  (hash-set! AI.images i (bitmap/file (string-append "img/npc/" (number->string (+ i 1)) ".png"))))

; Creates the intial lane positions on which all NPCS are placed relative to
(define AI.npc-height -200)
(define AI.LANEX
  (for/list ([i ROAD.LANES])
    (+ SCENE.HALFWIDTH (/ ROAD.WIDTH -2) (* i (/ ROAD.WIDTH ROAD.LANES)))))

(define (speed game delta)
  (* delta (pos-y (gs-velocity game)) 0.8))

; Creates a list of random positions
; Uses an accumulator n to decide how many positions should be made
; a b c d ensure that no cars are initially placed on top of each other and place the next car a random position further than the last car,
; although an additional function is required to ensure the random positions dont overlap
; List ref will take the random number from rand-generator and run it in cond, so a random lane is selected without replacing constantly at a new lane.
(define (sum n lane-count)
  (if (< n AI.count)
    (local [
      (define q 800)
      (define y-offset (map (lambda (i) (* i q)) lane-count))
      (define randy (random 500)) (define r (random ROAD.LANES))
      (define x-offset (+ 35 (random (- (round (/ ROAD.WIDTH ROAD.LANES)) 70))))
      ]
      (cons
        (pos (+ (list-ref AI.LANEX r) x-offset) (- (list-ref y-offset r) randy))
        (sum (+ n 1) (list-increment lane-count r))))
    empty))


; Makes a list of 30 images to match the positions
; When the list is empty it appends the full list, until the total length is 81
(define (make-car-images x g)
  (if (< g AI.count)
    (cons (random AI.imagecount) (make-car-images x (+ g 1)))
    empty))

; Creates a list of AI.count random positions
(define mega
  (sum 0 (make-list ROAD.LANES 0)))

; Creates a list of AI.count vehicles
(define mega2 (make-car-images AI.images 0))

; Converts the lists of random positions and images to random car structs
(define (car-maker x y n)
  (if (< n AI.count)
    (cons (car (first x) (m2p 35) (first y)) (car-maker (rest x) (rest y) (+ n 1)))
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
(define (AI.cars) (car-maker mega mega2 0))
