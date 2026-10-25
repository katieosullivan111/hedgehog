#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "prototype.rkt")
(provide SCENE.WIDTH SCENE.HEIGHT SCENE.HALFHEIGHT SCENE.HALFWIDTH draw truck1 truck2 truck3 car1 car2 car3 car4 car5 car6 BOOST EXTRALIFE)

(define SCENE.WIDTH  1000)
(define SCENE.HEIGHT  1000)
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))
(define SCENE.BG  (empty-scene SCENE.WIDTH SCENE.HEIGHT))

(define CAR.WIDTH (m2p 2))
(define CAR.LENGTH (m2p 5))
(define CAR (bitmap "car.png"))
;Other Vehicles For Testing

(define truck1 (bitmap "truck1.png"))
(define car1 (bitmap "car1.png"))
(define car2 (bitmap "car2.png"))
(define car3 (bitmap "car3.png"))
(define car4 (bitmap "car4.png"))
(define car5 (bitmap "car5.png"))
(define car6 (bitmap "car6.png"))
(define truck2 (bitmap "truck2.png"))
(define truck3 (bitmap "truck3.png"))
(define LIFE1 (bitmap "LIFE1.png"))
(define LIFE2 (bitmap "LIFE2.png"))
(define LIFE3 (bitmap "LIFE3.png"))
(define BOOST (bitmap "BOOST.png"))
(define EXTRALIFE (bitmap "EXTRALIFE.png"))

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
  (text (string-append "Score: " (number->string (round (/ (+ (- (pos-y (gs-player game))) 500) 10)))) 12 "red") ;Score text
  (text (string-append "Lives: " (number->string (gs-lives game))) 18 "blue") ; Lives text
  truck1
  truck2
  truck3
  car1
  car2
  car3
  car4
  car5
  car6
  BOOST
  EXTRALIFE
  )
  (list
      (pos (- (pos-x (gs-player game)) (pos-x (gs-camera game))) (- (pos-y (gs-player game)) (pos-y (gs-camera game))))
      (pos 50 10) ; Speed text
      (pos 50 40) ; Score text
      (pos 50 70)
      (pos (- (pos-x (gs-truck1 game)) (pos-x (gs-camera game))) (- (pos-y (gs-truck1 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-truck2 game)) (pos-x (gs-camera game))) (- (pos-y (gs-truck2 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-truck3 game)) (pos-x (gs-camera game))) (- (pos-y (gs-truck3 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-car1 game)) (pos-x (gs-camera game))) (- (pos-y (gs-car1 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-car2 game)) (pos-x (gs-camera game))) (- (pos-y (gs-car2 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-car3 game)) (pos-x (gs-camera game))) (- (pos-y (gs-car3 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-car4 game)) (pos-x (gs-camera game))) (- (pos-y (gs-car4 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-car5 game)) (pos-x (gs-camera game))) (- (pos-y (gs-car5 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-car6 game)) (pos-x (gs-camera game))) (- (pos-y (gs-car6 game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-BOOST game)) (pos-x (gs-camera game))) (- (pos-y (gs-BOOST game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-EXTRALIFE game)) (pos-x (gs-camera game))) (- (pos-y (gs-EXTRALIFE game)) (pos-y (gs-camera game))))
      )))
