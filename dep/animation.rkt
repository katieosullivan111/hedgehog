#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "header.rkt")
(require "physics.rkt")
(require "AI.rkt")
(provide TICK-animation draw ROAD.LANEOFFSET)

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

(define SCENE.BG  (overlay ROAD (rectangle SCENE.WIDTH SCENE.HEIGHT 'solid 'green)))

(define STEERINGWHEEL (scale 0.7 (bitmap "../img/drivingwheel.png")))

(define CAR (bitmap "../img/car.png"))
(define CAR.WIDTH (m2p 2))
(define CAR.LENGTH (m2p 5))

(define HEART (scale 0.15 (bitmap "../img/life.png")))
(define BOOST (bitmap "../img/BOOST.png"))
(define EXTRATIME (bitmap "../img/stopwatch.png"))
(define NAVIGATION-BAR (rectangle 800 8 'solid 'grey))
(define BOOST-BAR (rectangle 20 8 'solid 'red))
(define LIFE-BAR (rectangle 20 8 'solid 'blue))

; Utility Functions
(define (construct-lanes y) ; Constructs a list of positions of the lanes
  (map (lambda (x)
    (pos x (+ y ROAD.LANEOFFSET))) ROAD.STRIPEX)) ; how high it should be = the offset to give it overflow

(define (draw-scene imgs posns) ; Draw scene from lists of images and positions
  (foldl
    (lambda (img posn scene) (place-image img (pos-x posn) (pos-y posn) scene))
    SCENE.BG
    imgs
    posns))
  
; Update Functions
(define (TICK-animation game)
  (set-gs-lane-y! game (modulo (round (- (pos-y (gs-camera game)))) (+ ROAD.STRIPESPACING ROAD.STRIPEHEIGHT))) game)

(define (draw game)
  (if (gs? game)
    (let* (
      [xcam (pos-x (gs-camera game))]
      [ycam (pos-y (gs-camera game))]
      [x (pos-x (gs-player game))]
      [y (pos-y (gs-player game))]
      [countdown-raw (/ (round (/ (- (gs-deadline game) (gs-t game)) 100)) 10)]
      [countdown (round countdown-raw)]
      [distance (round (p2m (- y)))]
      [d (/ (- (gs-deadline game) (gs-t game)) 1000)])
      (draw-scene
        `( ; Last item in list is on top
          ; Road
          ,@ROAD.LANEIMAGES
          ,(text "DRIVE FAST!" 70 'red)

          ,BOOST
          ,EXTRATIME

          ,@(if (< y AI.HEADSTART) (map (lambda (i) (hash-ref AI.images (car-index i))) (gs-cars game)) empty)

          ,(rotate (gs-spin game) CAR)

          ; HUD
          ,NAVIGATION-BAR
          ,BOOST-BAR
          ,LIFE-BAR

          ,(rotate (* (gs-wheel game) -9) STEERINGWHEEL)

          ,(text (string-append (number->string (gs-fps game)) " FPS") 16 'red) ; FPS
          ,(text (string-append (number->string (round (* 3.6 (p2m (pos-y (gs-velocity game)))))) " km/h") 36 'blue) ; Speed text
          ,(text (string-append (number->string distance) " m") 16 'red) ; Score text
          ,(text (string-append (number->string (p2m (round (abs (- (pos-y (gs-player game)) (pos-y (gs-EXTRATIME game))))))) " m until next EXTRATIME") 16 'blue) ; Time until next icon


          ,HEART
          ,(text (number->string (gs-lives game)) 70 'white) ; Lives

          ,(text (string-append (number->string (- (* (gs-km game) 1000) distance)) " m") 32 'blue) ; Metre Countdown
          ,(text (string-append (number->string (if (<= countdown 10) countdown-raw countdown)) " s")
            (cond
              [(>= d 10) 32]
              [(>= d 5) 40]
              [else 48])
            (cond
              [(>= d 10) 'green]
              [(>= d 5) 'orange]
              [else 'red])) ; Countdown
        )
        `(
          ; Road
          ,@(construct-lanes (gs-lane-y game)) ; Lanes
          ,(pos SCENE.HALFWIDTH (- -400 ycam)) ; Warning
          
          ,(pos (- (pos-x (gs-BOOST game)) xcam) (- (pos-y (gs-BOOST game)) ycam)) ; Boost
          ,(pos (- (pos-x (gs-EXTRATIME game)) xcam) (- (pos-y (gs-EXTRATIME game)) ycam)) ; Extralife

          ,@(if (< y AI.HEADSTART)
            (map
              (lambda (car)
                (pos (pos-x (car-pos car)) (- (pos-y (car-pos car)) ycam)))
              (gs-cars game))
            empty)

          ,(pos (- x xcam) (- y ycam)) ; Player

          ; HUD
          ,(pos SCENE.HALFWIDTH 4) ; Navbar
          ,(pos (pos-x (gs-BOOST game)) 4) ;Sets the rectangle to show the next BOOST'S x co-ordinate
          ,(pos (pos-x (gs-EXTRATIME game)) 4)

          ,(pos 100 (- SCENE.HEIGHT 100)) ; Steering Wheel
          
          ,(pos 50 10) ; FPS
          ,(pos SCENE.HALFWIDTH (- SCENE.HEIGHT 30)) ; Speed text
          ,(pos 50 25) ; Score text
          ,(pos 110 50) ; Time until next EXTRATIME

          ,(pos (- SCENE.WIDTH 100) 100) ; Heart
          ,(pos (- SCENE.WIDTH 100) 105) ; Lives

          ,(pos SCENE.HALFWIDTH 30) ; Metre countdown
          ,(pos SCENE.HALFWIDTH 70) ; Countdown
        )
    ))
    (draw-scene
      `(
        ,@ROAD.LANEIMAGES

        ,(text (ts-heading game) 60 'yellow)
        ,(text (ts-subheading game) 20 'red)
        ,(text "Made by: Jack, Katie, and Tiernan" 20 'green)
      )
      `(
        ,@(construct-lanes (modulo (round (- (ts-mouse-y game))) (+ ROAD.STRIPESPACING ROAD.STRIPEHEIGHT)))

        ,(pos SCENE.HALFWIDTH SCENE.HALFHEIGHT)
        ,(pos SCENE.HALFWIDTH (+ SCENE.HALFHEIGHT 140))
        ,(pos SCENE.HALFWIDTH (- SCENE.HEIGHT 50))
      ))))
