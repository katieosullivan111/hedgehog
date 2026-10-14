#lang racket
(provide (struct-out pos) (struct-out gs))

(struct pos (x y))
(struct gs (camera player velocity accelerator) #:mutable) ; Game State