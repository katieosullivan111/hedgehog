#lang racket
(require "prototype.rkt")
(provide physics-update)

(define acceleration 1)
(define (physics-update game)
  ; Acceleration
  (when (not (and (= (gs-accelerator game) -1) (= (pos-y (gs-velocity game)) 0)))
    (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (- (pos-y (gs-velocity game)) (* (gs-accelerator game) acceleration)))))
  ; Update Player Position
  (set-gs-player! game (pos (+ (pos-x (gs-player game)) (pos-x (gs-velocity game))) (+ (pos-y (gs-player game)) (pos-y (gs-velocity game)))))
  game)