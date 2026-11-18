#lang racket
(require "header.rkt")
(provide TICK-physics)

; Constants
(define g 9.8) ; m/s^2
(define CAR.Cd 0.7) ; Co-eff of drag
(define CAR.AREA 1.7) ; m^2
(define CAR.MASS 800) ; kg
(define CAR.TORQUE 250) ; Nm
(define CAR.WHEELRADIUS 0.3) ; m
(define CAR.DRIVERATIO 6) ; Total Drive Ratio
(define CAR.MAXRPM 20000) ; Max RPM
(define CAR.MAXSPEED (/ (* CAR.MAXRPM 2 pi CAR.WHEELRADIUS) (* 60 CAR.DRIVERATIO))) ; m/s

; Forces
(define CAR.BRAKEPOWER (* 1.2 g CAR.MASS)) ; N
(define rolling-resistance (* 0.015 CAR.MASS g)) ; N
(define traction (/ (* CAR.TORQUE CAR.DRIVERATIO) CAR.WHEELRADIUS)) ; N
(define (drag v) (* 0.5 CAR.Cd CAR.AREA (sqr v))) ; N
(define (netforce v a d) ; velocity accelerator delta
  (if (and (= a 1) (< v CAR.MAXSPEED))
    (- traction rolling-resistance (drag v))
    (if (> v 0) (- 0 (if (= a -1) CAR.BRAKEPOWER 0) rolling-resistance (drag v)) (/ (* v CAR.MASS -1) d)))) ; N

; Mechanics
(define CAR.MAXSTEER 30) ; Max Steering Angle (degrees)
(define (steer-omega d) (* 50 d)) ; Steering angular velocity (degrees/second)
(define (steer-wheel game delta)
  (local [
    (define a
      (max
        (- CAR.MAXSTEER) ; Keep wheel rotation within physical bounds
        (min
          CAR.MAXSTEER
          (+
            (gs-wheel game)
            (* (steer-omega delta)
              (if (= (gs-steering game) 0)
                  (cond [(> (gs-wheel game) 0) -1] [(< (gs-wheel game) 0) 1] [else 0]) ; Wheel snap-back
                  (gs-steering game))))))) ; User steer
    ]
    (if (and (= (gs-steering game) 0) (< (abs a) 1)) 0 a)))

; Ensures player stays on the road
(define (check-player-bounds game)
  (let
    ([x (pos-x (gs-player game))] [y (pos-y (gs-player game))]
    [vx (pos-x (gs-velocity game))]
    [bound-l (- SCENE.HALFWIDTH (/ ROAD.WIDTH 2) 15)] [bound-r (+ SCENE.HALFWIDTH (/ ROAD.WIDTH 2) 15)])

    (when (or (< x bound-l) (> x bound-r))
      (set-gs-lives! game (- (gs-lives game) 1)) ; Reduce lives
      ; (set-gs-player! game (pos (+ bound-l 20) y))
      (set-gs-wheel! game (p2m (- vx)))))) ; Rebound

; tick
(define (TICK-physics game delta)
  (set-gs-wheel! game (steer-wheel game delta)) ; Steer update

  (local [
    (define xspeed (m2p (gs-wheel game)))
    (define yspeed (pos-y (gs-velocity game)))
    (define a (/ (netforce (p2m yspeed) (gs-accelerator game) delta) CAR.MASS)) ; Acceleration
    (define newyspeed (max 0 (+ yspeed (m2p (* a delta)))))]
    (set-gs-velocity! game (pos xspeed newyspeed))

    ; Update Position
    (set-gs-player! game
    (pos
      (+ (pos-x (gs-player game)) (* xspeed delta))
      (- (pos-y (gs-player game)) (* newyspeed delta))))

    (check-player-bounds game)

  ; Camera update
  (set-gs-camera! game (pos 0 (- (pos-y (gs-player game)) SCENE.CAMERAHEIGHT)))
  game)
)
