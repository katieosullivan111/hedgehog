#lang racket
(provide (all-defined-out))
; (provide
;     (struct-out pos)
;     (struct-out posr)
;     (struct-out gs)
;     m2p p2m
;     d2r r2d
;     pos2d abspos)

; General
(struct pos (x y)) ; Position Structure
(struct posr (x y r)) ; Position Structure with rotation
(struct gs (t fps camera player velocity accelerator wheel steering) #:mutable) ; Game State
; <number (s)> <number> <vector> <vector3d> <vector> <int [-1, 1]> <number (degrees)> <int [-1, 1]>

; Unit conversion
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters
(define (d2r d) (* d (/ pi 180))) ; degrees to radians
(define (r2d r) (* r (/ 180 pi))) ; radians to degrees
(define (pos2d p default) ; pos to degrees
    (if (and (= (pos-x p) 0) (= (pos-y p) 0))
        default
        (- (r2d (atan (pos-y p) (pos-x p))) 90)))
(define (abspos p) ; Absolute value of pos
    (sqrt (+ (sqr (pos-x p)) (sqr (pos-y p)))))

; Animation
(define MAXFPS 240)
(define SCENE.WIDTH  1000)
(define SCENE.HEIGHT  1000)
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))
(define SCENE.CAMERAHEIGHT (- SCENE.HEIGHT 200))