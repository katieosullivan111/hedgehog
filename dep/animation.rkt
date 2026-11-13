#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "header.rkt")
(require "physics.rkt")
(provide TICK-animation draw)

; Value Definitions
(define ROAD.COLOUR (make-color 096 096 096))
(define ROAD (beside
  (rectangle 30 SCENE.HEIGHT 'solid ROAD.COLOUR)
  (rectangle 10 SCENE.HEIGHT 'solid 'yellow)
  (rectangle ROAD.WIDTH SCENE.HEIGHT 'solid ROAD.COLOUR)
  (rectangle 10 SCENE.HEIGHT 'solid 'yellow)
  (rectangle 30 SCENE.HEIGHT 'solid ROAD.COLOUR)))
(define ROAD.STRIPE (rectangle 6 ROAD.STRIPEHEIGHT 'solid 'white))
(define ROAD.WHITESPACE (rectangle 6 ROAD.STRIPESPACING 'solid ROAD.COLOUR))
(define ROAD.LANEIMAGES
  (make-list ROAD.LANES ; Make a list of lanes
    (apply above (build-list ; Build list of alternating stripes and gaps
      (+ (* (round (/ SCENE.HEIGHT ROAD.STRIPESPACING)) 2) 2) ; No. of stripes + whitespace on screen
      (lambda (i)
        (if (= (modulo i 2) 0) ROAD.STRIPE ROAD.WHITESPACE))))))
(define ROAD.LANEOFFSET (- (/ (image-height (first ROAD.LANEIMAGES)) 2) (+ ROAD.STRIPEHEIGHT ROAD.STRIPESPACING))) ; To bring co-ordinate origin from image centre to top left
(define ROAD.left-lane-x (+ SCENE.HALFWIDTH (/ ROAD.WIDTH -2) (/ ROAD.WIDTH ROAD.LANES 2)))

(define SCENE.BG  (overlay ROAD (rectangle SCENE.WIDTH SCENE.HEIGHT 'solid 'green)))

; (define STEERINGWHEEL (add-line (circle 80 "solid" "black") 80 80 80 0 "blue"))
(define STEERINGWHEEL (scale 0.3 (bitmap "../img/steering-wheel.png")))

(define CAR (bitmap "../img/car.png"))
(define CAR.WIDTH (m2p 2))
(define CAR.LENGTH (m2p 5))

; Utility Functions
(define (construct-lanes y) ; Constructs a list of positions of the lanes
  (for/list ([i ROAD.LANES])
    (pos
      (+ ROAD.left-lane-x (* i (/ ROAD.WIDTH ROAD.LANES)))
      (+ y ROAD.LANEOFFSET))))

(define (draw-scene imgs posns) ; Draw scene from lists of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))
  
; Update Functions
(define (TICK-animation game)
  (set-gs-lane-y! game (modulo (round (- (pos-y (gs-camera game)))) (+ ROAD.STRIPESPACING ROAD.STRIPEHEIGHT))) game)

(define (draw game)
   (draw-scene
    `( ; Last item in list is on top
      ,@ROAD.LANEIMAGES
      ,CAR
      ,(rotate (* (gs-wheel game) -9) STEERINGWHEEL)

      ,(text (string-append (number->string (round (* 3.6 (p2m (pos-y (gs-velocity game)))))) " km/h") 16 "red") ; Speed text
      ,(text (string-append "Score: " (number->string (round (* 3.6 (p2m (- (pos-y (gs-player game)))))))) 16 "red") ; Score text
      ,(text (string-append (number->string (gs-fps game)) " FPS") 16 "red") ; FPS
    )
    `(
      ,@(construct-lanes (gs-lane-y game)) ; Lanes
      ,(pos (- (pos-x (gs-player game)) (pos-x (gs-camera game))) (- (pos-y (gs-player game)) (pos-y (gs-camera game)))) ; Player
      ,(pos 100 (- SCENE.HEIGHT 100)) ; Steering Wheel

      ,(pos 50 10) ; Speed text
      ,(pos 50 25) ; Score text
      ,(pos 50 40) ; FPS
    )
))
