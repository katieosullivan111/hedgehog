#lang racket
(require "prototype.rkt")
(require 2htdp/image)
(provide give-velocity mega mega2 los-coches nee-naw vroom-vroom  vehicles lane  cars ll)

;NPC images from https://publicdomainvectors.org
(define truck1 (bitmap "truck1.png"))
(define car1 (bitmap "car1.png"))
(define car2 (bitmap "car2.png"))
(define car3 (bitmap "car3.png"))
(define car4 (bitmap "car4.png"))
(define car5 (bitmap "car5.png"))
(define car6 (bitmap "car6.png"))
(define truck2 (bitmap "truck2.png"))
(define truck3 (bitmap "truck3.png"))
(define car7 (bitmap "car7.png"))
(define car8 (bitmap "car8.png"))
(define car9 (bitmap "car9.png"))

;List of all NPC images
(define vehicles (list truck1 truck2 truck3 car1 car2 car3 car4 car5 car6 car7 car8 car9))
 
;This function takes the list of NPCS and changes their positions to have constant velocity, which is proportional to the player's distance/score
(define (give-velocity x game)
  (if (empty? x)
      empty
      (cons (car (pos (pos-x (car-pos (first x)))
                 (- (pos-y (car-pos (first x))) (speed game))) (car-image (first x)))
            (give-velocity (rest x) game)))) 


  (define (speed game)
    (local [(define r (random 3))]
  (cond
    [(> (pos-y (gs-player game)) -1000) (+ r 1)]
    [(and (< (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (+ r 3)]
    [(and (< (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (+ r 5)]
    [(and (< (pos-y (gs-player game)) -3000) (> (pos-y (gs-player game)) -4000)) (+ r 7)]
    [(and (< (pos-y (gs-player game)) -4000) (> (pos-y (gs-player game)) -5000)) (+ r 9)]
    [(and (< (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -6000)) (+ r 10)]
    [(and (< (pos-y (gs-player game)) -6000) (> (pos-y (gs-player game)) -7000)) (+ r 12)]
    [(and (< (pos-y (gs-player game)) -7000) (> (pos-y (gs-player game)) -8000)) (+ r 15)]
    [(and (< (pos-y (gs-player game)) -8000) (> (pos-y (gs-player game)) -9000)) (+ r 17)]
    [(< (pos-y (gs-player game)) -9000) (+ r 19)])))


(define ll car-n) ;list length

;Creates the intial lane positions on which all NPCS are placed relative to
(define lane
  (list (pos 200 -300)
       (pos 400 -300)
       (pos 600 -300) 
       (pos 800 -300)))

;Creates a list of random positions
;Uses an accumulator n to decide how many positions should be made
;a b c d ensure that no cars are initially placed on top of each other and place the next car a random position further than the last car,
;although an additional function is required to ensure the random positions dont overlap
;List ref will take the random number from rand-generator and run it in cond, so a random lane is selected without replacing constantly at a new lane.
(define (sum n a b c d) 
  (if (<= n ll)
      (local [(define q 600) (define e (* a q)) (define f (* b q)) (define g (* c q)) (define h (* d q))
  (define randy (random 400))  (define r (random 4))
(define plus-or-minus (if (even? r)
   (random 100)
   (- (random 100))))]
          (cons
      (cond
        [(= r 0) (pos (+ (pos-x (first lane)) plus-or-minus) (- (pos-y (first lane)) (+ e randy)))]
        [(= r 1) (pos (+ (pos-x (second lane)) plus-or-minus) (- (pos-y (second lane)) (+ f randy)))]
        [(= r 2) (pos (+ (pos-x (third lane)) plus-or-minus) (- (pos-y (third lane)) (+ g randy)))]
        [else (pos (+ (pos-x (fourth lane)) plus-or-minus) (- (pos-y (fourth lane)) (+ h randy)))])
        (cond
        [(= r 0) (sum (+ n 1) (+ a 1) b c d)]
        [(= r 1) (sum (+ n 1) a (+ b 1) c d)]
        [(= r 2) (sum (+ n 1) a b (+ c 1) d)]
        [else (sum (+ n 1) a b c (+ d 1))])))
      empty))


;Makes a list of ;;images to match the positions
;When the list is empty it appends the full list, until the total length is 81
(define (make-more-vehicles x g)
      (if (<= g ll)
          (cons (list-ref vehicles (random 11)) (make-more-vehicles x (+ g 1)))
          empty))

;Creates a list of ll random positions
(define mega
  (sum 0 0 0 0 0))

;Creates a list of ll vehicles
(define mega2 (make-more-vehicles vehicles 0))

;Converts the lists of random positions and images to random car structs
(define (car-maker x y n)
  (if (<= n ll)
      (cons (car (list-ref x n) (list-ref y n)) (car-maker x y (+ n 1)))
      empty))

;Conerts the lane positions to a pos relative to the camera to be placed in draw
(define (cars x game)
  (if (empty? x)
      empty
      (cons (pos (- (pos-x (first x)) (pos-x (gs-camera game))) (- (pos-y (first x))
                                                                             (pos-y (gs-camera game))))
            (cars (rest x) game))))


;Determines how many images are taken depending on the player's position
(define (nee-naw game)
  (map car-image (gs-cars game)))

;Determines how many positions are taken depending on the player's position
(define (vroom-vroom game)
 (cars (map car-pos (gs-cars game)) game))


;Makes the list of car struct which is passed to the initial gs-cars
(define los-coches (car-maker mega mega2 0))
