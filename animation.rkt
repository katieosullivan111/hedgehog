#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require "prototype.rkt")
(require "physics.rkt")
(provide SCENE.WIDTH SCENE.HEIGHT SCENE.HALFHEIGHT SCENE.HALFWIDTH updatebackground draw)

(define SCENE.WIDTH  1000)
(define SCENE.HEIGHT  1000)
(define SCENE.HALFHEIGHT (/ SCENE.HEIGHT 2))
(define SCENE.HALFWIDTH (/ SCENE.WIDTH 2))

(define road-colour (make-color 096 096 096))
(define road (beside
              (rectangle 10 SCENE.HEIGHT 'solid 'grey)
              (rectangle 800 SCENE.HEIGHT 'solid road-colour)
              (rectangle 10 SCENE.HEIGHT 'solid 'grey)
              ))

(define ROADSTRIPE (rectangle 6 30 'solid 'white))

(define stripes-imgs (make-list 15 ROADSTRIPE))




 (define SCENE.BG  (overlay road (rectangle SCENE.WIDTH SCENE.HEIGHT 'solid 'white)))
;(define SCENE.BG  (empty-scene SCENE.WIDTH SCENE.HEIGHT ))


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

; below are some previous versions of the function quoted out, just because the function still isnt fully working, this way i can compare  
  ;(define stripe (first (gs-stripes game)))
  #|
  (define updated-stripes
    (map (lambda stripe)
   
  (if (> (- (y) (pos-y (gs-camera game))) SCENE.HEIGHT)
    (set-gs-stripes! game (cons (pos (pos-x (first gs-stripes game)) (- (pos-y (first gs-stripes game)) SCENE.HEIGHT)) #|(rest (gs-stripes game))|#))
                     gs-stripes game))
  (set-gs-stripes! updated-stripes)
  game)
|#

  
#|(define (updatebackground2 game)
  (define stripe (first (gs-stripes game)))
  (when (> (- (pos-y stripe) (pos-y (gs-camera game))) SCENE.HEIGHT)
    (set-gs-stripes! game (cons (pos (pos-x stripe) (- (pos-y stripe) SCENE.HEIGHT)) (rest (gs-stripes game)))))
  game)
|#      
#|     
(define (update-stripe stripe)
  (if (> (- (pos-y stripe) (pos-y (gs-camera game))) SCENE.HEIGHT)
    (set-stripe! (cons (pos (pos-x stripe) (- (pos-y stripe) SCENE.HEIGHT)) #|(rest (gs-stripes game)|#)))
    stripe)

  )
|#
#|
(define (updatebackground game)
  (define stripes (gs-stripes game))

(map (lambda (stripe game)
     (if (> (- (pos-y stripe) (pos-y (gs-camera game))) SCENE.HEIGHT)
         (set! stripe (cons (pos (pos-x stripe) (- (pos-y stripe) SCENE.HEIGHT)) #|(rest (gs-stripes game)|#))
    stripe))
       (stripes game)
       )
  game)   
     ;(update-stripe (gs-stripes game)))
|#
(define (updatebackground game)
  
    (define stripes (gs-stripes game))
     (define (new-stripes player-y)
(map (lambda (stripe)


       
     (if (> (- (pos-y stripe) (pos-y (gs-camera game))) SCENE.HEIGHT)
         (pos (pos-x stripe) (- (pos-y stripe) SCENE.HEIGHT) )
    ;(pos (pos-x stripe) (-(pos-y stripe) player-y));    here currently the stripes keep moving on the screen even when the car is stopped
         (pos (pos-x stripe) (+ (pos-y stripe) (/ (pos-y (gs-velocity game)) fps)   ;here the stripes stop/slow with the car, but disappear prematurely
       )))) stripes ))
   
    (set-gs-stripes! game (new-stripes (pos-y (gs-player game) ) ;    
     ))
   
  ;)
  game)

(define (draw-scene imgs posns) ; Draw scene from list of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))

(define (draw game)
   (draw-scene
    `( ; Last item in list is on top
     ;ROADSTRIPE
     
     ,@stripes-imgs

     
      ,CAR
      ,(text (string-append (number->string (round (* 3.6 (p2m (pos-y (gs-velocity game)))))) " km/h") 12 "red") ; Speed text
  ,(text (string-append "Score: " (number->string (round (* 3.6 (p2m (- (pos-y (gs-player game)))))))) 12 "red") ;Score text
  ,(text (number->string (- (pos-y (first (gs-stripes game))) (pos-y (gs-camera game)))) 12 "red")
  ,truck1
  ,truck2
  ,truck3
  ,car1
  ,car2
  ,car3)
   
   

   
    `(
     ;(pos 500 (stripe-position game (pos-y (gs-stripe1 game)))) ;TO BE RETURNED TO !!!!!!!!
     
     ;(pos 300 (- (pos-y (first (gs-stripes game))) (pos-y (gs-camera game))))
      
      ,@(map (lambda (stripe) (pos (pos-x stripe) (- (pos-y stripe) (pos-y (gs-camera game)) ) )) (gs-stripes game))
     ,(pos (- (pos-x (gs-player game)) (pos-x (gs-camera game))) (- (pos-y (gs-player game)) (pos-y (gs-camera game))))
      ,(pos 50 10) ; Speed text
      ,(pos 50 40) ; Score text
      ,(pos 70 100)
      ,(pos (pos-x (gs-truck1 game)) (pos-y (gs-truck1 game)))
      ,(pos (pos-x (gs-truck2 game)) (pos-y (gs-truck2 game)))
      ,(pos (pos-x (gs-truck3 game)) (pos-y (gs-truck3 game)))
      ,(pos (pos-x (gs-car1 game)) (pos-y (gs-car1 game)))
      ,(pos (pos-x (gs-car2 game)) (pos-y (gs-car2 game)))
      ,(pos (pos-x (gs-car3 game)) (pos-y (gs-car3 game))))

     
))
    

           