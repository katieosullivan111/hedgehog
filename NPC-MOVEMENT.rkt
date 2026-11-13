#lang racket
(require "prototype.rkt")
(require 2htdp/image)
(provide give-velocity mega mega2 los-coches nee-naw vroom-vroom purepos pureimages vehicles lane gap cars q ll currentclasher)

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
(define car10 (bitmap "car10.png"))



;List of all NPC images
(define vehicles (list truck1 truck2 truck3 car1 car2 car3 car4 car5 car6 car7 car8 car9 car10))
 
;This function takes the list of NPCS and changes their positions to have constant velocity, which is proportional to the player's distance/score
(define (give-velocity x game)
  (if (empty? x)
      empty
      (cons (car (pos (pos-x (car-pos (first x)))
                 (- (pos-y (car-pos (first x))) (speed game))) (car-image (first x)))
            (give-velocity (rest x) game)))) 


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


(define ll 29) ;list length

;Creates the intial lane positions on which all NPCS are placed relative to
(define lane
  (list (pos 250 -300)
       (pos 400 -300)
       (pos 550 -300) 
       (pos 700 -300)))

;Creates a random list of numbers from 0-3 which sum reads and assigns a random number of cars to each lane depending on this list
;Cant be generated inside the function as it will keep replacing the npcs at random points
(define (rg g)
  (if (<= g ll)
      (cons (random 4) (rg (+ g 1)))
      empty))

;Creates the list of random numbers
(define q (rg 0))

;Creates a list of random positions
;Uses an accumulator n to decide how many positions should be made
;a b c d ensure that no cars are initially placed on top of each other and place the next car a random position further than the last car,
;although an additional function is required to ensure the random positions dont overlap
;List ref will take the random number from rand-generator and run it in cond, so a random lane is selected without replacing constantly at a new lane.
(define (sum n a b c d) 
  (if (<= n ll)
      (local [(define e (* a 800)) (define f (* b 800)) (define (rg g)
  (if (<= g ll)
      (cons (random 4) (rg (+ g 1)))
      empty)) (define g (* c 800)) (define h (* d 800)) (define randy (random 900)) 
(define plus-or-minus (if (even? (list-ref q (random ll)))
   (random 100)
   (- (random 100))))]
          (cons
      (cond
        [(= (list-ref q n) 0) (pos (+ (pos-x (first lane)) plus-or-minus) (- (pos-y (first lane)) (+ e randy)))]
        [(= (list-ref q n) 1) (pos (+ (pos-x (second lane)) plus-or-minus) (- (pos-y (second lane)) (+ f randy)))]
        [(= (list-ref q n) 2) (pos (+ (pos-x (third lane)) plus-or-minus) (- (pos-y (third lane)) (+ g randy)))]
        [else (pos (+ (pos-x (fourth lane)) plus-or-minus) (- (pos-y (fourth lane)) (+ h randy)))])
        (cond
        [(= (list-ref q n) 0) (sum (+ n 1) (+ a 1) b c d)]
        [(= (list-ref q n) 1) (sum (+ n 1) a (+ b 1) c d)]
        [(= (list-ref q n) 2) (sum (+ n 1) a b (+ c 1) d)]
        [else (sum (+ n 1) a b c (+ d 1))])))
      empty))


;Makes a list of 30 images to match the positions
;When the list is empty it appends the full list, until the total length is 81
(define (make-more-vehicles x g)
      (if (<= g ll)
          (cons (list-ref vehicles (random 11)) (make-more-vehicles x (+ g 1)))
          empty))

;Creates a list of 81 random positions
(define mega
  (sum 0 0 0 0 0))

;Creates a list of 30 vehicles
(define mega2 (make-more-vehicles vehicles 0))

;;Extracts the cars-pos from the gs and allows us to select a certain number of them
(define (list-maker-cars x game)
  (take (cars (purepos game) game) x))

;Extracts the car-images from the gs and allows us to select a certain number of them
(define (list-maker-vehicles x game)
  (take (pureimages game) x))

(define (list-maker-gs x game)
  (take (gs-cars game) x))

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


(define (gap game)
(cond
    [(< (pos-y (gs-velocity game)) 50)
  (+ (pos-y (gs-player game)) 1000)]
    [(and (>= (pos-y (gs-velocity game)) 50) (< (pos-y (gs-velocity game)) 100))
  (+ (pos-y (gs-player game)) 1500)]
    [(and (>= (pos-y (gs-velocity game)) 100) (< (pos-y (gs-velocity game)) 175))
 (+ (pos-y (gs-velocity game)) 2000)]
      [else  (+ (pos-y (gs-player game)) 2500)]))
 


;Determines how many images are taken depending on the player's position
(define (nee-naw game)
  (cond
    [(> (pos-y (gs-player game)) -5000)
  (list-maker-vehicles 10 game)]
    [(and (<= (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -10000))
  (list-maker-vehicles 15 game)]
    [(and (<= (pos-y (gs-player game)) -10000) (> (pos-y (gs-player game)) -15000))
 (list-maker-vehicles 20 game)]
      [else 
 (list-maker-vehicles 30 game)]))

;Determines how many positions are taken depending on the player's position
(define (vroom-vroom game)
  (cond
    [(> (pos-y (gs-player game)) -5000) (list-maker-cars 10 game)]
    [(and (<= (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -10000)) (list-maker-cars 15 game)]
    [(and (<= (pos-y (gs-player game)) -10000) (> (pos-y (gs-player game)) -15000)) (list-maker-cars 20 game)]
    [else (list-maker-cars 30 game)]))

(define (currentclasher game)
  (cond
    [(> (pos-y (gs-player game)) -5000) (list-maker-gs 10 game)]
    [(and (<= (pos-y (gs-player game)) -5000) (> (pos-y (gs-player game)) -10000)) (list-maker-gs 15 game)]
    [(and (<= (pos-y (gs-player game)) -10000) (> (pos-y (gs-player game)) -15000)) (list-maker-gs 20 game)]
    [else (list-maker-gs 30 game)]))


(define sorter
  (sort mega (lambda (e f) (< (pos-y e) (pos-y f)))))
;Makes the list of 81 cars which is passed to the initial gs-cars
(define los-coches (car-maker sorter mega2 0))

;Extracts car-pos
(define (purepos game)
  (map car-pos (gs-cars game)))

;Extracts car-image
(define (pureimages game)
  (map car-image (gs-cars game)))
