#lang racket
(require 2htdp/image)
(require 2htdp/universe)

; Local Modules
(require "prototype.rkt")
(require "physics.rkt")
(require "animation.rkt")

; Constants
(define move-size 20)

; Initialise Game State
(define init (gs (pos 0 0) (pos SCENE.HALFWIDTH SCENE.HALFHEIGHT) (pos 0 0) 0))

; Ticking and Animation
(define (tick game) (set-gs-camera! (physics-update game) (pos 0 (- (pos-y (gs-player game)) SCENE.HALFHEIGHT))) game)

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