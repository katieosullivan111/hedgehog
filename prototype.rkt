#lang racket
(provide (struct-out pos) (struct-out gs) (struct-out car) m2p p2m)

(struct pos (x y)) ; Position Structure
(struct gs (camera player velocity accelerator lives BOOST EXTRALIFE cars) #:mutable #:transparent) ; Game State
(struct car (pos image)) ; Stores a NPC position and its image
(define (m2p m) (* m 20)) ; meters to pixels
(define (p2m p) (/ p 20)) ; pixels to meters

