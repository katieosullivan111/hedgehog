#lang racket
(require 2htdp/image)
(require 2htdp/universe)

; Local Modules
(require "prototype.rkt")
(require "physics.rkt")
(require "animation.rkt")

; Initialise Game State
(define init (gs (pos 0 0) (posr SCENE.HALFWIDTH SCENE.HALFHEIGHT 0) (pos 0 0) 0 0 0))

; Tick Update
(define (tick game) (physics-update game))

; Event Handlers
(define (keydown game k)
  (case k
    [("w") (set-gs-accelerator! game 1) game]
    [("s") (set-gs-accelerator! game -1) game]
    [("a") (set-gs-steering! game 1) game]
    [("d") (set-gs-steering! game -1) game]
    [else game]))
(define (keyup game k)
  (case k
    [("w") (set-gs-accelerator! game 0) game]
    [("s") (set-gs-accelerator! game 0) game]
    [("a") (when (equal? (gs-steering game) 1) (set-gs-steering! game 0)) game]
    [("d") (when (equal? (gs-steering game) -1) (set-gs-steering! game 0)) game]
    [else game]))

; Start the game
(big-bang init [on-tick tick] [to-draw draw] [on-key keydown] [on-release keyup])