#lang racket
(require 2htdp/image)
(require "prototype.rkt")
(provide draw)

(define SCENE.BG  (empty-scene SCENE.WIDTH SCENE.HEIGHT)) ; Background
(define STEERINGWHEEL (add-line (circle 80 "solid" "black") 80 80 80 0 "blue"))
; (define CAR.WIDTH (m2p 2))
; (define CAR.LENGTH (m2p 5))
(define CAR (overlay/offset (bitmap "car.png") 0 -35 (circle 100 "solid" "transparent"))) ; Offset rotation centre of to the front axle)

(define (draw-scene imgs posns) ; Draw scene from list of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))

(define (draw game)
  (draw-scene
    (list ; Last item in list is on top
      (rotate (posr-r (gs-player game)) CAR)
      (rotate (* (gs-wheel game) 9) STEERINGWHEEL)
      (text (string-append (number->string (round (* 3.6 (p2m (abspos (gs-velocity game)))))) " km/h") 12 "red") ; Speed text
    )
    (list
      (pos (- (posr-x (gs-player game)) (pos-x (gs-camera game))) (- (posr-y (gs-player game)) (pos-y (gs-camera game)))) ; Car
      (pos 100 (- SCENE.HEIGHT 100)) ; Steering Wheel
      (pos 50 10) ; Speed text
)))