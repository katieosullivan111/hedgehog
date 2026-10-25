#lang racket
(require 2htdp/image)
(require 2htdp/universe)

; Local Modules
(require "prototype.rkt")
(require "physics.rkt")
(require "animation.rkt")
(require "collisions-update.rkt")
(require "NPC-MOVEMENT.rkt")


; Constants
(define move-size 20)

; Initialise Game State
(define init (gs (pos 0 0) (pos SCENE.HALFWIDTH SCENE.HALFHEIGHT) (pos 0 0) 0 3 
                 (pos 150 200) (pos 100 200) (pos 300 200) (pos 400 -300) (pos 340 -350) (pos 290 -400) (pos 600 -250) (pos 700 -500) (pos  0 SCENE.HALFHEIGHT)
                 (pos 800 -500) (pos 500 -500)))


; Ticking and Animation
(define (tick game) (set-gs-camera! (physics-update game) (pos 0 (- (pos-y (gs-player game)) SCENE.HALFHEIGHT))) (collisions-update game) (NPC-MOVEMENT game) game)



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

;Termination Clauses
(define (lives-update game)
  (set-gs-lives! game 3))

(define (game-over? game)
   (if (= (gs-lives game) 0)
       #true
       #false))   


; Start the game
(big-bang init [on-tick tick] [to-draw draw] [on-key keydown] [on-release keyup] [stop-when game-over?])