#lang racket
(require 2htdp/image)
(require 2htdp/universe)

; Local Modules
(require "prototype.rkt")
(require "physics.rkt")
(require "animation.rkt")

; Initialise Game State
(define init (gs
    (/ (current-inexact-milliseconds) 1000) 1 ; time and fps
    (pos 0 0) (pos SCENE.HALFWIDTH 0) (pos 0 (m2p 2)) ; camera, player, velocity vectors
    0 ; accelerator input
    0 0 ; wheel rotation and steering input
    3 ; lives
    (list ; stripes
      (list 0 200 400 600 800) ; Lane 1
      (list 0 200 400 600 800) ; Lane 2
      (list 0 200 400 600 800)) ; Lane 3
  ))
;maybe should create function for stripes initial positions

; Ticking and Animation
(define (tick game)
  (local [
          (define now (/ (current-inexact-milliseconds) 1000))
          (define delta (min (- now (gs-t game)) 0.1)) ; delta time between frames, limit to 10 fps
        ]
        (physics-update game delta)
        (set-gs-t! game now)
        (when (= (modulo (round (* now 10)) 5) 0)
          (set-gs-fps! game (round (/ 1000 (round (* 1000 delta))))))
        
        (updatebackground game)
        game))

; Event Handlers
(define (keydown game k)
  (case k
    [("w") (set-gs-accelerator! game 1) game]
    [("s") (set-gs-accelerator! game -1) game]
    [("a") (set-gs-steering! game -1) game]
    [("d") (set-gs-steering! game 1) game]
    [else game]))
(define (keyup game k)
  (case k
    [("w") (set-gs-accelerator! game 0) game]
    [("s") (set-gs-accelerator! game 0) game]
    [("a") (when (equal? (gs-steering game) -1) (set-gs-steering! game 0)) game]
    [("d") (when (equal? (gs-steering game) 1) (set-gs-steering! game 0)) game]
    [else game]))

;Termination Clauses
(define (lives-update game)
  (set-gs-lives! game 3))

(define (game-over? game)
   (if (= (gs-lives game) 0)
       #true
       #false))

; Start the game
(big-bang init [on-tick tick (/ 1 MAXFPS)] [to-draw draw] [on-key keydown] [on-release keyup] [stop-when game-over?])
