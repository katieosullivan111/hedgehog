#lang racket
(require "prototype.rkt")
(provide physics-update)

; Constants
(define mu 0.7) ; Co-eff of friction
(define g 9.8) ; m/s^2
(define CAR.Cd 0.7) ; Co-eff of drag
(define CAR.AREA 1.7) ; m^2
(define CAR.MASS 800) ; kg
(define CAR.TORQUE 250) ; Nm
(define CAR.WHEELRADIUS 0.3) ; m
(define CAR.DRIVERATIO 6) ; Total Drive Ratio
(define CAR.MAXRPM 20000) ; Max RPM
(define CAR.WHEELBASE 2.7) ; m
(define CAR.MAXSPEED (/ (* CAR.MAXRPM 2 pi CAR.WHEELRADIUS) (* 60 CAR.DRIVERATIO))) ; m/s

; Forces
(define CAR.BRAKEPOWER (* 1.2 g CAR.MASS)) ; N
(define friction (* mu CAR.MASS g)) ; N
(define rolling-resistance (* 0.015 CAR.MASS g)) ; N
(define traction (/ (* CAR.TORQUE CAR.DRIVERATIO) CAR.WHEELRADIUS)) ; N
(define (drag v) (* 0.5 CAR.Cd CAR.AREA (sqr v))) ; N
(define (netforce v a d) ; velocity accelerator delta
  (if (and (= a 1) (< v CAR.MAXSPEED))
    (- traction rolling-resistance (drag v))
    (if (> v 0) (- 0 (if (= a -1) CAR.BRAKEPOWER 0) rolling-resistance (drag v)) (/ (* v CAR.MASS -1) d)))) ; N

; Mechanics
(define steer-max 30) ; Max Steering Angle (degrees)
(define (steer-omega v d) (* (/ 2 (log (+ (abspos v) 5)) d))) ; Steering angular velocity (degrees/second)
(define (steer-wheel game delta)
  (max (- steer-max) ; Keep wheel rotation within physical bounds
    (min
      steer-max
      (round (+ (gs-wheel game)
      (if (= (gs-steering game) 0)
          (cond [(> (gs-wheel game) 0) -1] [(< (gs-wheel game) 0) 1] [else 0]) ; Wheel snap-back
          (* (steer-omega (gs-velocity game) delta) (gs-steering game)))))))) ; User steer

; tick
(define (physics-update game delta)
  ; Steering & Acceleration
  (set-gs-wheel! game (steer-wheel game delta))

  (define speed (abspos (gs-velocity game)))
  (define newspeed (max 0 (+ speed (m2p (* (/ (netforce (p2m speed) (gs-accelerator game) delta) CAR.MASS) delta)))))

  (define currentdirection (d2r (posr-r (gs-player game))))
  (define turn-rate
    (/ (* (p2m newspeed) (tan (d2r (gs-wheel game))))
       CAR.WHEELBASE))
  (define nextdirection (+ currentdirection (* turn-rate delta)))
  (define direction (/ (+ currentdirection nextdirection) 2))

  (set-gs-velocity! game
    (pos (- (* newspeed (sin nextdirection)))
      (* newspeed (cos nextdirection))))

  ; Update Position
  (set-gs-player! game
    (posr
      (+ (posr-x (gs-player game)) (* (- (* newspeed (sin direction))) delta))
      (- (posr-y (gs-player game)) (* (* newspeed (cos direction)) delta))
      (r2d nextdirection)))
  ; Camera update
  (set-gs-camera! game (pos 0 (- (posr-y (gs-player game)) SCENE.CAMERAHEIGHT)))
  game
)