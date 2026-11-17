#lang racket
(require json)
(provide (all-defined-out))

; Read data from config file
(define config (call-with-input-file "config.json" read-json))

; General
(struct pos (x y)) ; Position Structure
(struct car (pos index)) ; position and image index
(struct gs (t fps camera player velocity accelerator wheel steering lives lane-y BOOST EXTRALIFE cars) #:mutable) ; Game State
; <number> <number> <pos> <pos> <pos> <int [-1, 1]> <number> <int [-1, 1]> <number> <number> <pos> <pos> <list<car>>
(struct ts (heading subheading exit)) ; Title State
; <string> <string> <boolean>

; Unit conversion
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters

; Utility
(define (list-increment lst i)
  (if (zero? i)
      (cons (add1 (first lst)) (rest lst))
      (cons (first lst) (list-increment (rest lst) (sub1 i)))))

; Animation
(define MAXFPS (hash-ref config 'max_fps))

(define ROAD.WIDTH 800)
(define SCENE.WIDTH (max(hash-ref (hash-ref config 'resolution) 'width) (+ ROAD.WIDTH 80)))
(define SCENE.HEIGHT (hash-ref (hash-ref config 'resolution) 'height))
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))
(define SCENE.CAMERAHEIGHT (- SCENE.HEIGHT 150))

(define ROAD.LANES 5)
(define ROAD.STRIPESPACING 150)
(define ROAD.STRIPEHEIGHT 50)
(define ROAD.STRIPES/LANE (quotient SCENE.HEIGHT ROAD.STRIPESPACING))

; AI
(define AI.count (hash-ref config 'npc-count))