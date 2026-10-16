#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "prototype.rkt")
(provide SCENE.WIDTH SCENE.HEIGHT SCENE.HALFHEIGHT SCENE.HALFWIDTH draw)

(define SCENE.WIDTH  1000)
(define SCENE.HEIGHT  1000)
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))
(define SCENE.BG  (empty-scene SCENE.WIDTH SCENE.HEIGHT))

(define CAR.WIDTH (m2p 2))
(define CAR.LENGTH (m2p 5))
(define CAR (bitmap "car.png"))
;Other Vehicles For Testing

(define truck1 (rectangle 5 15 'solid 'blue))
(define car1 (circle 20 'solid 'green))
(define car2 (circle 30 'solid 'green))
(define car3 (circle 30 'solid 'green))
(define truck2 (rectangle 5 15 'solid 'blue))
(define truck3 (rectangle 5 15 'solid 'blue))

(define (draw-scene imgs posns) ; Draw scene from list of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))

(define (draw game)
  (draw-scene
    (list ; Last item in list is on top
      CAR
      (text (string-append (number->string (round (* 3.6 (p2m (pos-y (gs-velocity game)))))) " km/h") 12 "red") ; Speed text
  (text (string-append "Score: " (number->string (round (* 3.6 (p2m (- (pos-y (gs-player game)))))))) 12 "red") ;Score text
  truck1
  truck2
  truck3
  car1
  car2
  car3)                                                                                                         (list
      (pos (- (pos-x (gs-player game)) (pos-x (gs-camera game))) (- (pos-y (gs-player game)) (pos-y (gs-camera game))))
      (pos 50 10) ; Speed text
      (pos 50 40) ; Score text
      (pos (pos-x (gs-truck1 game)) (pos-y (gs-truck1 game)))
      (pos (pos-x (gs-truck2 game)) (pos-y (gs-truck2 game)))
      (pos (pos-x (gs-truck3 game)) (pos-y (gs-truck3 game)))
      (pos (pos-x (gs-car1 game)) (pos-y (gs-car1 game)))
      (pos (pos-x (gs-car2 game)) (pos-y (gs-car2 game)))
      (pos (pos-x (gs-car3 game)) (pos-y (gs-car3 game))))
))