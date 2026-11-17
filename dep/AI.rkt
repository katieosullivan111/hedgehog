; Car images from https://publicdomainvectors.org

#lang racket
(require "header.rkt")
(require 2htdp/image)
(provide give-velocity mega mega2 AI.cars AI.images lane cars hlw)

;List of all vehicles
(define AI.images (build-list 12 (lambda (i)
  (bitmap/file (string-append "img/npc/" (number->string (+ i 1)) ".png")))))

;This function takes the list of NPCS and changes their positions to have constant velocity, which is proportional to the player's distance/score
(define (give-velocity x game)
  (if (empty? x)
      empty
      (cons (car (pos (pos-x (car-pos (first x)))
        (- (pos-y (car-pos (first x))) (speed game))) (car-index (first x)))
        (give-velocity (rest x) game))))

(define (speed game)
  (+
    (random 3)
    (cond
      [(> (pos-y (gs-player game)) -1000) 1]
      [(> (pos-y (gs-player game)) -2000) 3]
      [(> (pos-y (gs-player game)) -3000) 5]
      [(> (pos-y (gs-player game)) -4000) 7]
      [(> (pos-y (gs-player game)) -5000) 9]
      [(> (pos-y (gs-player game)) -6000) 10]
      [(> (pos-y (gs-player game)) -7000) 12]
      [(> (pos-y (gs-player game)) -8000) 15]
      [(> (pos-y (gs-player game)) -9000) 17]
      [else 19])))

(define ROAD.left-lane-x (+ SCENE.HALFWIDTH (/ ROAD.WIDTH -2) (/ ROAD.WIDTH ROAD.LANES)))
;Creates the intial lane positions on which all NPCS are placed relative to
(define lane
   (for/list ([i ROAD.LANES])
    (pos
      (+ ROAD.left-lane-x (* (- i 1) (/ ROAD.WIDTH ROAD.LANES)))
      -200)))
(define hlw 70) ;half of lane-width
;Creates a list of random positions
;Uses an accumulator n to decide how many positions should be made
;a b c d ensure that no cars are initially placed on top of each other and place the next car a random position further than the last car,
;although an additional function is required to ensure the random positions dont overlap
;List ref will take the random number from rand-generator and run it in cond, so a random lane is selected without replacing constantly at a new lane.
(define (sum n lane-count)
  (if (<= n AI.count)
    (local [
      (define q 800)
      (define y-offset (map (lambda (i) (* i q)) lane-count))
      (define randy (random 800))  (define r (random 5))
      (define plus-or-minus
        (if (even? r) (random hlw) (- (random hlw))))
      ]
      (cons
        (pos (+ (pos-x (list-ref lane r)) plus-or-minus) (- (list-ref y-offset r) randy))
        (sum (+ n 1) (list-increment lane-count r))))
    empty))


;Makes a list of 30 images to match the positions
;When the list is empty it appends the full list, until the total length is 81
(define (make-more-vehicles x g)
  (if (<= g AI.count)
    (cons (list-ref AI.images (random 11)) (make-more-vehicles x (+ g 1)))
    empty))

;Creates a list of AI.count random positions
(define mega
  (sum 0 (make-list ROAD.LANES 0)))

;Creates a list of AI.count vehicles
(define mega2 (make-more-vehicles AI.images 0))

;Converts the lists of random positions and images to random car structs
(define (car-maker x y n)
  (if (<= n AI.count)
    (cons (car (list-ref x n) (list-ref y n)) (car-maker x y (+ n 1)))
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
