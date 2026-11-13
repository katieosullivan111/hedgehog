#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "prototype.rkt")
(require "physics.rkt")
(provide updatebackground draw)

(define ROAD.COLOUR (make-color 096 096 096))
(define ROAD (beside
              (rectangle 10 SCENE.HEIGHT 'solid 'grey)
              (rectangle ROAD.WIDTH SCENE.HEIGHT 'solid ROAD.COLOUR)
              (rectangle 10 SCENE.HEIGHT 'solid 'grey)
              ))
(define ROAD.STRIPE (rectangle 6 30 'solid 'white))
(define stripes-imgs (make-list 15 ROAD.STRIPE))
(define SCENE.BG  (overlay ROAD (rectangle SCENE.WIDTH SCENE.HEIGHT 'solid 'white)))

(define STEERINGWHEEL (add-line (circle 80 "solid" "black") 80 80 80 0 "blue"))

(define CAR (bitmap "car.png"))
(define CAR.WIDTH (m2p 2))
(define CAR.LENGTH (m2p 5))

(define (updatebackground game)
  (local [
    (define stripes (gs-stripes game))
    (define (new-stripes player-y)
      (map (lambda (x)
        (map (lambda (y)
          (if (> (- y (pos-y (gs-camera game))) SCENE.HEIGHT)
            (- y SCENE.HEIGHT)
            (+ y (/ (pos-y (gs-velocity game)) (gs-fps game))) ;here the stripes stop/slow with the car, but disappear prematurely
          )) x))
        stripes))
  ]
  (set-gs-stripes! game (new-stripes (pos-y (gs-player game) )))
  game))
(define (parse-stripes list)
  (map (lambda (stripe) (pos (pos-x stripe) (- (pos-y stripe) (pos-y (gs-camera game)) ) )) (gs-stripes game)))

(define (draw-scene imgs posns) ; Draw scene from lists of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))

(define (draw game)
   (draw-scene
    `( ; Last item in list is on top
     ,@stripes-imgs
     
      ,CAR
      ,(rotate (* (gs-wheel game) -9) STEERINGWHEEL)
      ,(text (string-append (number->string (round (* 3.6 (p2m (pos-y (gs-velocity game)))))) " km/h") 12 "red") ; Speed text
      ,(text (string-append (number->string (gs-fps game)) " FPS") 12 "red") ; FPS
      ,(text (string-append "Score: " (number->string (round (* 3.6 (p2m (- (pos-y (gs-player game)))))))) 12 "red") ; Score text
    )
    `(
     ;(pos 500 (stripe-position game (pos-y (gs-stripe1 game)))) ;TO BE RETURNED TO !!!!!!!!
     
     ;(pos 300 (- (pos-y (first (gs-stripes game))) (pos-y (gs-camera game))))
      ,@(parse-stripes (gs-stripes game))
      ,(pos (- (pos-x (gs-player game)) (pos-x (gs-camera game))) (- (pos-y (gs-player game)) (pos-y (gs-camera game))))
      ,(pos 100 (- SCENE.HEIGHT 100)) ; Steering Wheel
      ,(pos 50 10) ; Speed text
      ,(pos 50 30) ; FPS
      ,(pos 50 40) ; Score text
    )
))
