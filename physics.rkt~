#lang racket
(require "prototype.rkt")
(provide physics-update)

; Constants
(define fps 30) ; Frames per second
(define mu 0.7) ; Co-eff of friction
(define g 9.8) ; m/s^2
(define CAR.Cd 0.7) ; Co-eff of drag
(define CAR.AREA 1.7) ; m^2
(define CAR.MASS 800) ; kg
(define CAR.TORQUE 150) ; Nm
(define CAR.WHEELRADIUS 0.3) ; m
(define CAR.DRIVERATIO 8) ; Total Drive Ratio
(define CAR.MAXRPM 20000) ; Max RPM
(define CAR.MAXSPEED (/ (* CAR.MAXRPM 2 pi CAR.WHEELRADIUS) (* 60 CAR.DRIVERATIO))) ; m/s
; Forces
(define CAR.BRAKEPOWER (* 1.2 g CAR.MASS)) ; N
(define friction (* mu CAR.MASS g)) ; N
(define rolling-resistance (* 0.015 CAR.MASS g)) ; N
(define traction (/ (* CAR.TORQUE CAR.DRIVERATIO) CAR.WHEELRADIUS)) ; N
(define (drag v) (* 0.5 CAR.Cd CAR.AREA (sqr v))) ; N
(define (netforce v a)
  (if (and (= a 1) (< v CAR.MAXSPEED))
    (- traction rolling-resistance (drag v))
    (if (> v 0) (- 0 (if (= a -1) CAR.BRAKEPOWER 0) rolling-resistance (drag v)) (* v CAR.MASS fps -1)))) ; N

(define (physics-update game)
  ; Acceleration
  (set-gs-velocity! game (pos (pos-x (gs-velocity game)) (+ (pos-y (gs-velocity game)) (m2p (/ (netforce (p2m (pos-y (gs-velocity game))) (gs-accelerator game)) CAR.MASS fps)))))
  ; Update Player Position
  (set-gs-player! game (pos (+ (pos-x (gs-player game)) (pos-x (gs-velocity game))) (- (pos-y (gs-player game)) (/ (pos-y (gs-velocity game)) fps))))
  game)
  
  