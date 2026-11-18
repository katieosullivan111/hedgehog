#lang racket
(require json)
(provide (all-defined-out))

; Read data from config file
(define config (call-with-input-file "config.json" read-json))

; General
(struct pos (x y)) ; Position Structure
(struct car (pos speed index)) ; position and image index
(struct gs (t fps deadline km camera player velocity accelerator wheel steering lives lane-y BOOST EXTRALIFE cars) #:mutable) ; Game State
; <number> <number> <number> <number> <pos> <pos> <pos> <int [-1, 1]> <number> <int [-1, 1]> <number> <number> <pos> <pos> <list<car>>
(struct ts (heading subheading mouse-y exit)) ; Title State
; <string> <string> <boolean>

; Unit conversion
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters

; Utility
(define (list-increment list i) ; Increments i-th term in list by 1
  (if (zero? i)
    (cons (add1 (first list)) (rest list))
    (cons (first list) (list-increment (rest list) (sub1 i)))))

; Animation
(define MAXFPS (hash-ref config 'max_fps))

(define ROAD.WIDTH 800)
(define SCENE.WIDTH (max(hash-ref (hash-ref config 'resolution) 'width) (+ ROAD.WIDTH 80)))
(define SCENE.HEIGHT (hash-ref (hash-ref config 'resolution) 'height))
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))
(define SCENE.CAMERAHEIGHT (- SCENE.HEIGHT 150))

(define ROAD.LANES 7)
(define ROAD.STRIPESPACING 150)
(define ROAD.STRIPEHEIGHT 50)
(define ROAD.STRIPES/LANE (quotient SCENE.HEIGHT ROAD.STRIPESPACING))

(define ROAD.STRIPEX
   (for/list ([i (- ROAD.LANES 1)])
      (+ SCENE.HALFWIDTH (/ ROAD.WIDTH -2) (/ ROAD.WIDTH ROAD.LANES) (* i (/ ROAD.WIDTH ROAD.LANES)))))

; Physics & AI
(define CAR.E 0.7) ; Co-efficient of Restitution between player and other cars
(define CAR.MAXSTEER 30) ; Max Steering Angle (degrees)
(define AI.HEADSTART (m2p (- 50))) ; AI doesn't spawn until player has traveled 100m
(define AI.count (round (* SCENE.HEIGHT 0.01 (hash-ref config 'traffic-density)))) ; traffic-density = #traffic per 100 pixels
