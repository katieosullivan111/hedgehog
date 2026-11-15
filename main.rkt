#lang racket
(require 2htdp/image)
(require 2htdp/universe)

; Local Modules
(require "prototype.rkt")
(require "physics.rkt")
(require "animation.rkt")
(require "collisions-update.rkt")
(require "NPC-MOVEMENT.rkt")

; Initialise Game State
(define init (gs (/ (current-inexact-milliseconds) 1000) 1
                 (pos 0 0) (pos SCENE.HALFWIDTH 0) (pos 0 (m2p 2)) 0
                 0 0
                 3 ;lives
                 (pos (+ (random 800) 100) (+ (random 800) 100))
                 (pos (+ (random 800) 100) (+ (random 800) 100))
                 (list (pos 300 200) (pos 500 100) (pos 700 200) (pos 300 400) (pos 500 300) (pos 700 400) (pos 300 600) (pos 500 500) (pos 700 600) (pos 500 700) (pos 300 800) (pos 500 900) (pos 700 800) (pos 300 0) (pos 700 0)) ; stripes
         los-coches))
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
      
        (vroom-vroom game) (nee-naw game) (collisions-update game) game))

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

;game-over clause
(define (game-over? game)
   (if (= (gs-lives game) 0)
       #true
       #false))

; Start the game
(big-bang init [on-tick tick (/ 1 MAXFPS)] [to-draw draw] [on-key keydown] [on-release keyup] [stop-when game-over?])
