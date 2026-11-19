; Car images from https://publicdomainvectors.org

#lang racket
(require "header.rkt")
(require 2htdp/image)
(provide AI.cars AI.images AI.imagecount AI.LANEX AI.LANESPEEDS AI.deceleration)

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

(define AI.deceleration (m2p 2)) ; Decelerates (m/s/s) to reach target speed when too fast
(define AI.LANESPEEDS (make-hash)) ; Table for target lane speed
(for/list ([i ROAD.LANES])
  (hash-set! AI.LANESPEEDS i (m2p (+ 30 (* i 5))))) ; (ie. First lane 30 m/s target)

(define (speed game delta)
  (* delta (pos-y (gs-velocity game)) 0.7))

; Creates a list of n random positions of cars
(define (make-car-pos n no./lane) ; no./lane = no. of cars per lane <list>
  (if (< n AI.count)
    (let* (
      [base-split 1200] ; base separation between cars
      [lane (random ROAD.LANES)] ; lane index of this car
      [y-offset (* (list-ref no./lane lane) base-split)]
      [randy (random 500)] ; Randomiser to alter distance between cars
      [x-offset (+ 35 (random (- (round (/ ROAD.WIDTH ROAD.LANES)) 70)))] ; horizontal offset from default lane position
    )
      (cons
        (list (pos (+ (list-ref AI.LANEX lane) x-offset) (- y-offset randy)) lane)
        (make-car-pos (+ n 1) (list-increment no./lane lane))))
    empty))

(define (make-car-images x i) ; Generates list of i image indexes
  (if (< i AI.count)
    (cons (random AI.imagecount) (make-car-images x (+ i 1)))
    empty))

; Converts the lists of random positions and images to random car structs
(define (car-maker x y i)
  (if (< i AI.count)
    (cons (car (first (first x)) (hash-ref AI.LANESPEEDS (second (first x))) (second (first x)) (first y)) (car-maker (rest x) (rest y) (+ i 1)))
    empty))

; Makes the list of car struct which is passed to the initial gs-cars
(define (AI.cars) (local [
  (define (create-pos-list) (make-car-pos 0 (make-list ROAD.LANES 0))) ; Creates a list of AI.count random positions
  (define (create-image-list) (make-car-images AI.images 0))] ; Creates a list of AI.count vehicles

  (car-maker (create-pos-list) (create-image-list) 0)))
