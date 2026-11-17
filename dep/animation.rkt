#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "header.rkt")
(require "physics.rkt")
(require "AI.rkt")
(provide TICK-animation draw ROAD.LANEOFFSET ROAD.left-lane-x)

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
  (make-list (- ROAD.LANES 1) ; Make a list of lanes
    (apply above (build-list ; Build list of alternating stripes and gaps
      (+ (* (round (/ SCENE.HEIGHT ROAD.STRIPESPACING)) 2) 2) ; No. of stripes + whitespace on screen
      (lambda (i)
        (if (= (modulo i 2) 0) ROAD.STRIPE ROAD.WHITESPACE))))))
(define ROAD.LANEOFFSET (- (/ (image-height (first ROAD.LANEIMAGES)) 2) (+ ROAD.STRIPEHEIGHT ROAD.STRIPESPACING))) ; To bring co-ordinate origin from image centre to top left
(define ROAD.left-lane-x (+ SCENE.HALFWIDTH (/ ROAD.WIDTH -2) (/ ROAD.WIDTH ROAD.LANES)))
;takes to left by dividing by minus road width and adds lane width to get across full screen
(define SCENE.BG  (overlay ROAD (rectangle SCENE.WIDTH SCENE.HEIGHT 'solid 'green)))

(define STEERINGWHEEL (scale 0.7 (bitmap "../img/drivingwheel.png")))

(define CAR (bitmap "../img/car.png"))
(define CAR.WIDTH (m2p 2))
(define CAR.LENGTH (m2p 5))

(define BOOST (bitmap "../img/BOOST.png"))
(define EXTRALIFE (bitmap "../img/life.png"))
(define NAVIGATION-BAR (rectangle 800 8 'solid 'grey))
(define BOOST-BAR (rectangle 20 8 'solid 'red))
(define LIFE-BAR (rectangle 20 8 'solid 'blue))

; Utility Functions
(define (construct-lanes y) ; Constructs a list of positions of the lanes
  (for/list ([i (- ROAD.LANES 1)])
    (pos
      (+ ROAD.left-lane-x (* i (/ ROAD.WIDTH ROAD.LANES))) ;6 lanes means 1/6th of the lane
      (+ y ROAD.LANEOFFSET)))) ;how high it should be = the offset to give it overflow

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
  (if (gs? game)
    (let (
      [xcam (pos-x (gs-camera game))]
      [ycam (pos-y (gs-camera game))])
      (draw-scene
        `( ; Last item in list is on top
          ; Road
          ,@ROAD.LANEIMAGES
          ,(text "DRIVE FAST!" 70 'red)

          ,BOOST
          ,EXTRALIFE

          ,@(map car-index (gs-cars game))

          ,CAR

          ; HUD
          ,NAVIGATION-BAR
          ,BOOST-BAR
          ,LIFE-BAR

          ,(rotate (* (gs-wheel game) -9) STEERINGWHEEL)

          ,(text (string-append (number->string (round (* 3.6 (p2m (pos-y (gs-velocity game)))))) " km/h") 16 'red) ; Speed text
          ,(text (string-append "Score: " (number->string (round (p2m (- (pos-y (gs-player game))))))) 16 'red) ; Score text
          ,(text (string-append (number->string (gs-fps game)) " FPS") 16 'red) ; FPS
          ,(text (string-append "Lives: " (number->string (gs-lives game))) 18 'blue) ; Lives
        )
        `(
          ; Road
          ,@(construct-lanes (gs-lane-y game)) ; Lanes
          ,(pos SCENE.HALFWIDTH (- -400 ycam)) ; Warning
          
          ,(pos (- (pos-x (gs-BOOST game)) xcam) (- (pos-y (gs-BOOST game)) ycam)) ; Boost
          ,(pos (- (pos-x (gs-EXTRALIFE game)) xcam) (- (pos-y (gs-EXTRALIFE game)) ycam)) ; Extralife

          ,@(map
            (lambda (car)
              (pos (pos-x (car-pos car)) (- (pos-y (car-pos car)) ycam)))
            (gs-cars game))

          ,(pos (- (pos-x (gs-player game)) xcam) (- (pos-y (gs-player game)) ycam)) ; Player

          ; HUD
          ,(pos SCENE.HALFWIDTH 4) ; Navbar
          ,(pos (pos-x (gs-BOOST game)) 4) ;Sets the rectangle to show the next BOOST'S x co-ordinate
          ,(pos (pos-x (gs-EXTRALIFE game)) 4)

          ,(pos 100 (- SCENE.HEIGHT 100)) ; Steering Wheel
          
          ,(pos 50 10) ; Speed text
          ,(pos 50 25) ; Score text
          ,(pos 50 40) ; FPS
          ,(pos 50 70) ; Lives
        )
    ))
    (draw-scene
      `(
        ,(text (ts-heading game) 60 'yellow)
        ,(text (ts-subheading game) 20 'red)
        ,(text "Made by: Jack, Katie, and Tiernan" 20 'green)
      )
      `(
        ,(pos SCENE.HALFWIDTH SCENE.HALFHEIGHT)
        ,(pos SCENE.HALFWIDTH (+ SCENE.HALFHEIGHT 140))
        ,(pos SCENE.HALFWIDTH (- SCENE.HEIGHT 50))
      ))))
