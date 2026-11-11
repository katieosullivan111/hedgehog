#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "prototype.rkt")
(require "NPC-MOVEMENT.rkt")
(provide SCENE.WIDTH SCENE.HEIGHT SCENE.HALFHEIGHT SCENE.HALFWIDTH draw)

(define SCENE.WIDTH  1000)
(define SCENE.HEIGHT  1000)
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))
(define SCENE.BG  (empty-scene SCENE.WIDTH SCENE.HEIGHT))

(define CAR.WIDTH (m2p 2))
(define CAR.LENGTH (m2p 5))
(define CAR (bitmap "car.png"))
(define BOOST (bitmap "BOOST.png"))
(define EXTRALIFE (bitmap "EXTRALIFE.png"))
(define NAVIGATION-BAR (rectangle 800 10 'solid 'grey))
(define BOOST-BAR (rectangle 20 10 'solid 'red))
(define LIFE-BAR (rectangle 20 10 'solid 'blue))
                   
;Creates a list of gs objects excluding NPCs
(define (objects game) (list ; Last item in list is on top
      CAR
      (text (string-append (number->string (round (* 3.6 (p2m (pos-y (gs-velocity game)))))) " km/h") 12 "red") ;Speed text
  (text (string-append "Score: " (number->string (round (/ (+ (- (pos-y (gs-player game))) 500) 10)))) 12 "red") ;Score text
  (text (string-append "Lives: " (number->string (gs-lives game))) 18 "blue") ;Lives text
  (text "MADE BY:" 70 "white")
  (text "JACK" 80 "white")
  (text "KATIE" 80 "white")
  (text "TIERNAN" 80 "white")
  BOOST
  EXTRALIFE
  NAVIGATION-BAR
  BOOST-BAR
  LIFE-BAR))


;Creates a list of gs positions excluding NPCs
(define (object-posns game) (list
      (pos (- (pos-x (gs-player game)) (pos-x (gs-camera game))) (- (pos-y (gs-player game)) (pos-y (gs-camera game))))
      (pos 50 10) ; Speed text
      (pos 50 40) ; Score text
      (pos 50 70) ; Lives text
      (pos 300 (- 100 (pos-y (gs-camera game))))
      (pos 300 (- 200 (pos-y (gs-camera game))))
      (pos 300 (- 300 (pos-y (gs-camera game))))
      (pos 300 (- 400 (pos-y (gs-camera game))))
     (pos (- (pos-x (gs-BOOST game)) (pos-x (gs-camera game))) (- (pos-y (gs-BOOST game)) (pos-y (gs-camera game))))
      (pos (- (pos-x (gs-EXTRALIFE game)) (pos-x (gs-camera game))) (- (pos-y (gs-EXTRALIFE game)) (pos-y (gs-camera game))))
      (pos 500 (+ (- (pos-y (gs-player game)) (pos-y (gs-camera game))) 350))
      (pos (pos-x (gs-BOOST game)) (+ (- (pos-y (gs-player game)) (pos-y (gs-camera game))) 350)) ;Sets the rectangle to show the next BOOST'S x-co-ordinate
      (pos (pos-x (gs-EXTRALIFE game)) (+ (- (pos-y (gs-player game)) (pos-y (gs-camera game))) 350)))) ;Sets the rectangle to show the next EXTRALIFE'S x-co-ordinate



(define (draw-scene imgs posns) ; Draw scene from list of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))    

(define (draw game)
  (draw-scene
     (append  (objects game) (nee-naw game)) ;Combines objects and NPCs to be placed
    (append  (object-posns game) (vroom-vroom game))))

