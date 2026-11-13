#lang racket
(provide (all-defined-out))

; General
(struct pos (x y)) ; Position Structure
(struct gs (t fps camera player velocity accelerator wheel steering lives truck1 truck2 truck3 car1 car2 car3 stripes) #:mutable) ; Game State

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
(define MAXFPS 60)
(define SCENE.WIDTH  1000)
(define SCENE.HEIGHT  700)
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))
(define SCENE.CAMERAHEIGHT (- SCENE.HEIGHT 200))
