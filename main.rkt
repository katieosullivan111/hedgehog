#lang racket
(require 2htdp/image)
(require 2htdp/universe)

; Local Modules
(require "dep/header.rkt")
(require "dep/physics.rkt")
(require "dep/animation.rkt")
(require "dep/AI.rkt")
(require "dep/collisions-update.rkt")

; Initialise Game State
(define (STATE.TITLESCREEN heading) (ts 
  heading ; heading
  "Press SPACE to go,\n\tor ESC to quit" ; Subheading
  0 ; y-position of mouse
  #f)) ; terminate boolean
(define (STATE.GAME) (gs
  (current-inexact-milliseconds) 1 (+ (current-inexact-milliseconds) 20000) 1 ; time, fps, time remaining, n-th km of travel
  (pos 0 0) (pos (- (first ROAD.STRIPEX) (/ ROAD.WIDTH ROAD.LANES 2)) 0) (pos 0 (m2p 2)) ; camera, player, velocity vectors
  0 ; accelerator input
  0 ; Car rotation
  0 0 ; wheel rotation and steering input
  MAXLIVES ; lives
  0 ; lane-y
  (pos -50 0) ; BOOST
  (pos -50 0) ; EXTRALIFE
  (AI.cars) ; list of cars
))

; Ticking and Animation
(define (tick game)
  (if (gs? game)
    (let* (
      [now (current-inexact-milliseconds)]
      [delta (min (- now (gs-t game)) 100)] ; delta time between frames, limit to >= 10 fps
      [delta-s (/ delta 1000)] ; delta in seconds
    )
    ; Update fps counter
    (set-gs-t! game now)
    (when (= (modulo (round now) 5) 0)
      (set-gs-fps! game (round (/ 1000 delta))))
    
    (if (or (timeout? game) (<= (gs-lives game) 0))
      (begin
        (set-gs-player! game (pos
          (+ (pos-x (gs-player game)) (* delta-s 1000))
          (- (pos-y (gs-player game)) (* delta-s 1000))))
        (set-gs-spin! game (+ (gs-spin game) (* delta-s 1000)))
        (set-gs-deadline! game now)
        (if (< (pos-x (gs-player game)) SCENE.WIDTH)
          game
          (STATE.TITLESCREEN "Driving Test:\n\tFAIL!")))
      (begin
        (TICK-physics game delta-s)
        (when (< (pos-y (gs-player game)) AI.HEADSTART) (collisions-update game delta-s))
        (TICK-animation game))))
    game)
  )

(define (timeout? game)
  (let ([distance (p2m (- (pos-y (gs-player game))))] [km (gs-km game)] [t (gs-t game)] [deadline (gs-deadline game)])
    (when (>= distance (* km 1000))
      (set-gs-deadline! game (+ deadline (* 1000 (- 20 km))))
      (set-gs-km! game (add1 km)))
    (if (> t deadline) #t #f)))

; Event Handlers
(define (keydown game k)
  (if (gs? game)
    (case k
      [("w") (set-gs-accelerator! game 1) game]
      [("s") (set-gs-accelerator! game -1) game]
      [("a") (set-gs-steering! game -1) game]
      [("d") (set-gs-steering! game 1) game]
      [else game])
    (case k
      [(" ") (STATE.GAME)]
      [("escape") (ts 0 0 0 #t)]
      [else game])))
(define (keyup game k)
  (if (gs? game)
    (case k
      [("w") (set-gs-accelerator! game 0) game]
      [("s") (set-gs-accelerator! game 0) game]
      [("a") (when (equal? (gs-steering game) -1) (set-gs-steering! game 0)) game]
      [("d") (when (equal? (gs-steering game) 1) (set-gs-steering! game 0)) game]
      [else game])
    game))

(define (mouse-event game x y me)
  (if (ts? game)
    (begin (ts (ts-heading game) (ts-subheading game) y #f))
    game))

(define (exit? game) (and (ts? game) (ts-exit game)))

; Start the game
(big-bang (STATE.TITLESCREEN "Hedgehog\n\tLicence") [on-tick tick (/ 1 MAXFPS)] [to-draw draw] [on-key keydown] [on-release keyup] [on-mouse mouse-event] [stop-when exit?])
