#lang racket
(require "prototype.rkt")
(require 2htdp/image)
(provide give-velocity mega mega2 truck1 truck2 truck3 car1 car2 car3 car4 car5 car6 vehicles los-coches nee-naw vroom-vroom purepos pureimages lane)

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


;List of all NPC images
(define vehicles (list truck1 truck2 truck3 car1 car2 car3 car4 car5 car6))
 
;This function takes the list of NPCS and changes their positions to have constant velocity, which is proportional to the player's distance/score
(define (give-velocity x game)
  (if (empty? x)
      empty
      (cons (car (pos (pos-x (car-pos (first x)))
                 (- (pos-y (car-pos (first x))) (speed game))) (car-image (first x)))
            (give-velocity (rest x) game)))) 

;Assigns NPCS a random velocity proprotional to the player's position/score
  (define (speed game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (+ (random 5) 1)]
    [(and (< (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (+ (random 5) 3)]
    [(and (< (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (+ (random 5) 5)]
    [(and (< (pos-y (gs-player game)) -3000) (> (pos-y (gs-player game)) -4000)) (+ (random 5) 7)]
    [(and (< (pos-y (gs-player game)) -4000) (> (pos-y (gs-player game)) -5000)) (+ (random 5) 9)]
    [(and (< (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -6000)) (+ (random 5) 10)]
    [(and (< (pos-y (gs-player game)) -6000) (> (pos-y (gs-player game)) -7000)) (+ (random 5) 12)]
    [(and (< (pos-y (gs-player game)) -7000) (> (pos-y (gs-player game)) -8000)) (+ (random 5) 15)]
    [(and (< (pos-y (gs-player game)) -8000) (> (pos-y (gs-player game)) -9000)) (+ (random 5) 17)]
    [(< (pos-y (gs-player game)) -9000) (+ (random 5) 20)]))

(define lw (random 150)) ; lane width

;Creates the intial lane positions on which all NPCS are placed relative to
(define lane
  (list (pos (+ lw 150) 300)
       (pos (+ lw 350) 300)
       (pos (+ lw 500) 300) 
       (pos (+ lw 650) 300)))

;Creates a random list of numbers from 0-3 which sum reads and assigns a random number of cars to each lane depending on this list
;Cant be generated inside the function as it will keep replacing the npcs at random points
(define (rand-generator g)
  (if (<= g 80)
      (cons (random 4) (rand-generator (+ g 1)))
      empty))


;Creates the list of random numbers
(define q (rand-generator 0))

;Creates a list of random positions
;Uses an accumulator n to decide how many positions should be made
;a b c d ensure that no cars are initially placed on top of each other and place the next car a random position further than the last car,
;although an additional function is required to ensure the random positions dont overlap
;List ref will take the random number from rand-generator and run it in cond, so a random lane is selected without replacing constantly at a new lane.
(define (sum n a b c d) 
  (if (<= n 80)
      (local [(define e (* a 600)) (define f (* b 600)) (define g (* c 600)) (define h (* d 600)) (define plus-or-minus
  (if (even? (list-ref q n))
      (+ (random 150))
      (- (random 150))))]
          (cons
      (cond
        [(= (list-ref q n) 0) (pos (+ (pos-x (first lane)) plus-or-minus) (- (pos-y (first lane)) (+ e (+ (random 500) 150))))]
        [(= (list-ref q n) 1) (pos (+ (pos-x (second lane)) plus-or-minus) (- (pos-y (second lane)) (+ f (+ (random 500) 150))))]
        [(= (list-ref q n) 2) (pos (+ (pos-x (third lane)) plus-or-minus) (- (pos-y (third lane)) (+ g (+ (random 500) 150))))]
        [else (pos (+ (pos-x (fourth lane)) plus-or-minus) (- (pos-y (fourth lane)) (+ h (+ (random 500) 150))))])
        (cond
        [(= (list-ref q n) 0) (sum (+ n 1) (+ a 1) b c d)]
        [(= (list-ref q n) 1) (sum (+ n 1) a (+ b 1) c d)]
        [(= (list-ref q n) 2) (sum (+ n 1) a b (+ c 1) d)]
        [else (sum (+ n 1) a b c (+ d 1))])))
      empty))

;Makes a list of 81 images to match the positions
;When the list is empty it appends the full list, until the total length is 81
(define (make-more-vehicles x g)
  (if (empty? x)
      (append x x)
      (if (<= g 80)
          (cons (list-ref vehicles (random 9)) (make-more-vehicles x (+ g 1)))
          empty)))

;Creates a list of 81 random positions
(define mega
  (sum 0 0 0 0 0))

;Creates a list of 81 vehicles
(define mega2 (make-more-vehicles vehicles 0))

;;Extracts the cars-pos from the gs and allows us to select a certain number of them
(define (list-maker-cars x game)
  (take (cars (purepos game) game) x))

;Extracts the car-images from the gs and allows us to select a certain number of them
(define (list-maker-vehicles game x)
  (take (pureimages game) x))


;Converts the lists of random positions and images to random car structs
(define (car-maker x y n)
  (if (<= n 80)
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
  (cond
    [(> (pos-y (gs-player game)) -1000)
  (list-maker-vehicles game 20)]
    [(and (<= (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000))
  (list-maker-vehicles game 40)]
    [(and (<= (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000))
 (list-maker-vehicles game 60)]
      [else 
 (list-maker-vehicles game 80)]))

;Determines how many positions are taken depending on the player's position
(define (vroom-vroom game)
  (cond
    [(> (pos-y (gs-player game)) -1000) (list-maker-cars 20 game)]
    [(and (<= (pos-y (gs-player game)) -1000) (> (pos-y (gs-player game)) -2000)) (list-maker-cars 40 game)]
    [(and (<= (pos-y (gs-player game)) -2000) (> (pos-y (gs-player game)) -3000)) (list-maker-cars 60 game)]
    [else (list-maker-cars 80 game)]))

;Makes the list of 81 cars which is passed to the initial gs-cars
(define los-coches (car-maker mega mega2 0))

;Extracts car-pos
(define (purepos game)
  (map car-pos (gs-cars game)))

;Extracts car-image
(define (pureimages game)
  (map car-image (gs-cars game)))