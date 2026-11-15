#lang racket
(require json)
(provide (all-defined-out))

; Read data from config file
(define config (call-with-input-file "config.json" read-json))

; General
(struct pos (x y) #:transparent) ; Position Structure
(struct car (pos index) #:transparent) ; position and image index
(struct gs (t fps camera player velocity accelerator wheel steering lives lane-y BOOST EXTRALIFE cars) #:mutable) ; Game State
; <number (s)> <number> <vector> <vector> <vector> <int [-1, 1]> <number (degrees)> <int [-1, 1]>

; Unit conversion
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters

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