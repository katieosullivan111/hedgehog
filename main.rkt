#lang racket
(require 2htdp/image)
(require 2htdp/universe)

; Local Modules
(require "prototype.rkt")
(require "physics.rkt")

; Constants
(define WIDTH  1000)
(define HEIGHT  500)
(define move-size 20)
 
(define BACKGROUND  (empty-scene WIDTH HEIGHT)) ; short for empty scene
(define CAR (rectangle 4 10 "solid" "red"))

; Initialise Game State
(define init (gs (pos 0 0) (pos (/ WIDTH 2) (/ HEIGHT 2)) (pos 0 0) 0))

; Ticking and Animation
(define (tick game) (physics-update game))
(define (draw game)
  (place-image CAR (- (pos-x (gs-player game)) (pos-x (gs-camera game))) (- (pos-y (gs-player game)) (pos-y (gs-camera game))) BACKGROUND))

; Event Handlers
(define (keydown game k)
  (cond
    [(key=? k "w") (set-gs-accelerator! game 1) game]
    [(key=? k "s") (set-gs-accelerator! game -1) game]
    [(key=? k "a") (set-gs-player! game (pos (- (pos-x (gs-player game)) move-size) (pos-y (gs-player game)))) game]
    [(key=? k "d") (set-gs-player! game (pos (+ (pos-x (gs-player game)) move-size) (pos-y (gs-player game)))) game]
    [else game]))
(define (keyup game k)
  (cond
    [(key=? k "w") (set-gs-accelerator! game 0) game]
    [(key=? k "s") (set-gs-accelerator! game 0) game]
    [else game]))

; Start the game
(big-bang init [on-tick tick] [to-draw draw] [on-key keydown] [on-release keyup])