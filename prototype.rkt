#lang racket
(provide (struct-out pos) (struct-out gs) m2p p2m)

(struct pos (x y)) ; Position Structure
(struct gs (camera player velocity accelerator lives truck1 truck2 truck3 car1 car2 car3) #:mutable) ; Game State
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters