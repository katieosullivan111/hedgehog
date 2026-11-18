# HEDEHOG CARS

## Contents
- Concept Statement
- Genre
- Target Audience
- Scope
- Language and Device
- Game Termination
- Score
- ITEMS
- Lives
- AI
- Difficulty
- Structs
- Controls
- UI and HUD
- Cammera
- Physics
- Steering
- Road
- Animation
- Tick
- Big-Bang
- json
- References

## Concept Statement
This is an explosive 2-D vertical scroller which sees the player avoid other vehicles while weaving through traffic to try and get as high a score as possible. The game incorporates realistic steering and increasing difficulty as the player's score increases.

## Genre
This game is a single-player, retro, 2-D scroller, with fast-paced racing.

## Target Audience
This game can be enjoyed by players of any age, it avoids violence or brutality which makes it suitable for younger audiences, but its retro style and simplistic control-system can also appeal to an older generation not looking to play a game which requires major time commitments.

## Scope
This game is intended to be a simple endless scroller.
The game contains a number of AI which can be easily adjusted by players or developers.
The road and lane systems form the template for how AI move and the lane numbers and scene height and width are also easily adjusted. There is only one map for player's to use.
Realistic physical quantities and models are used to describe the motion of the car along the road.
A steering system is in place to give the player a more immersive feel and the steering wheel icon displays the steering movement.
There are two power-ups, BOOST and EXTRALIFE, which affect the player's stats.
The game was made with a close deadline in mind so multiplayer and multi-level design were never seen as realistic targets.

## Language and Device
The game is written on ‘Racket’ in Racket’s native language (accessed by #lang racket) and can be used on PC, laptops or tablets with an additional keyboard accessory. 
Porting to other devices would not be too difficult, and should any future developers wish to do so they should mainly reference the ‘keydown’ and ‘key-up’ functions as well as adjust the display format.

## Game Termination
The game can end in two ways: 
-The user clicks the red stop button, prompting racket to stop running the programme.
-The user loses all of their lives and the programme stops running.

## Score
The player’s score is shown in the tope left. It is directly proportional to the y-position of the player, I.e the total distance travelled and can only be increased by moving further.

Score may be lost when a player collides with an AI, in which case it will move backwards a certain amount proportional to the player’s velocity in the y direction, thus decreasing their y position and score.


## ITEMS
There are two main items which the player can obtain: BOOST and EXTRALIFE.

The BOOST icon is denoted by a fuel can.
When the player comes within radius 60 (reference the `(touching? x game)` function in `collisions-update.rkt`.) of this item it increases their velocity by 200.
The item serves as a power-up in the beginning but may also be an obstacle to a player if they are in close proximity of an NPC as it will propel them into it.

The EXTRALIFE icon is denoted by a wheel.
When the player comes within radius 60 of this item it increases their life count by 1. This item can only be obtained when the player’s total lives are below 5, otherwise it will spawn out of bounds and cannot be obtained by the player until the lives count is below 5 again.

Both items spawn at random positions on start.
When the player moves past them their position is adjusted proportional to the player’s velocity (see `behind?`).
When the player touches the items, provided they meet the clauses to respawn in bounds, the BOOST will spawn at least 2000 units away and at most 3000.
The EXTRALIFE will spawn at least 10000 units away and at most 15000, as it is objectively more valuable.


## Lives
Lives can be lost in two ways. The first is when the player pushes past either of the outermost two lanes. Their position in the x direction will be adjusted by +100 or -100 depending on which side of the map they collide with. They will also lose a small proportion of their velocity.

The second way is when a player collides with an AI. The ‘(touching-cars x game)’ function in ‘collisions-update.rkt’ recursively checks that the absolute value of the distance between the player and AI in the x and y direction isn’t less than the sum of their widths or heights. When they do collide, the player’s velocity in the y-direction is decreased by 0.3 times its value and the player moves back ‘crash-distance’ which is proportional to its velocity.


## AI
The AI are initially assigned 1 lane position. A list is created using `for/list` and it is placed at an x-position at the centre of some lane, so even if the player or developer changes the number of lanes the AI will update accordingly.


The first AI is placed at a random choice of one of these five options

The sum function keeps creates .
For example if the first AI is placed in the second lane, then the next car placed in the second lane will be placed in that lane with at least 600 units between it and the first car. The x co-ordinates of each car can also be either  at most 75 more or 75 less than the lane positions, to give a random feel.

The same method is used for randomly selecting and creating a list of images, except previous cars don’t need to be tracked. `mega` and `mega2` store the two lists of desired lengths.

`cars` is used to create a list of the AI positions relative to the camera so it can be passed to draw.

(define (cars x game)
  (if (empty? x)
    empty
    (cons
      (pos (- (pos-x (first x)) (pos-x (gs-camera game)))
        (- (pos-y (first x)) (pos-y (gs-camera game))))
      (cars (rest x) game))))

`car-maker` takes the lists of positions and image index and uses list-ref to match up the corresponding elements of each list and use them to create a list of car-structs.

(define (car-maker x y n)
  (if (<= n AI.count)
    (cons (car (list-ref x n) (list-ref y n)) (car-maker x y (+ n 1)))
    empty))

`AI.cars` stores a list of the car-structs and is used in init to set gs-cars to that list of all AI cars.

The cars argument of the game state stores all of the car positions and images once they are generated.
The ‘(keep-cars x game)’ function in ‘collisions-update.rkt’ tracks if a car is too far behind or too far ahead of the player by partitioning the gs-cars list twice:
-Cars that are too far behind and all other cars
-All other cars and cars that are too far ahead
(take-gap x game) and (add-gap x game) then adjust their positions accordingly.
When a car falls out of bounds a new car is created, to keep a continuous random programme flowing.

(define (keep-cars? x game)
  (let-values ([(a b) (partition (lambda (y) (< (pos-y (car-pos y)) (+ (pos-y (gs-player game))
                1000))) x)])
    (let-values ([(c d) (partition (lambda (y) (< (pos-y (car-pos y)) (- (pos-y (gs-player game))
                2500))) a)])
    (append (add-gap b game) d (take-gap c game)))))

Collisions between AI are also avoided using partition, where the ‘checker’ function ecursively partitions the list and checks each cars position relative to every AI but itself and adjusts it if necessary.

(define (checker x game)
  (if (empty? x) 
      empty
  (let-values ([(i j) (partition (lambda (y) (<= (abs (- (pos-y (car-pos y)) (pos-y (car-pos (first x))))) 200)
    (<= (abs (- (pos-x (car-pos y)) (pos-x (car-pos (first x))))) 55))) (remove (first x) x))])
    (cons (first x) (append (add-small-gap i game) (checker j game))))))

Using the absolute value ensures collisions are checked all ways, but later iterations could improve on how the car reacts to collisions in a certain direction.

## Difficulty
The games difficulty automatically increases over time. As the game progresses, the minimum threshold for replacing cars ahead or behind decreases. This means that cars are sooner reached by the player, increasing traffic density.

The AI speed also grows with time, making it dangerous for the player’s speed to drop as cars could spawn suddenly from behind.

```
(define (respawn-condition x game)
  (cond
    [(> (pos-y (gs-player game)) -10000) x]
    [(and (<= (pos-y (gs-player game)) -10000) (> (pos-y (gs-player game)) -20000)) (* x 0.8)]
    [(and (<= (pos-y (gs-player game)) -20000) (> (pos-y (gs-player game)) -30000)) (* x 0.65)]
    [(and (<= (pos-y (gs-player game)) -30000) (> (pos-y (gs-player game)) -40000)) (* x 0.55)]
    [else (* x 0.45)]))
```

The game state list of AI is updated each tick, with gs-cars being set to a list which gives velocity to a list which checks if the AI are in bound and finally to a list which checks if the AI are touching or not.

(set-gs-cars! game (give-velocity (keep-cars? (checker (gs-cars game) game) game) game))

## Structs 
The game uses three structs:
- pos
- car
- gs.

The pos struct holds an x and y co-ordinate for each item, which makes items more convenient to place (accessed by (pos (pos-x__) (pos-y__)).)
The car struct holds a pos and an index (the index of its image in the list of images), which can be accessed by car-pos and car-image.
The gs struct is a mutable structure which holds:
- t (the time since from initialisation updated every frame)
- fps (the games current frames-per-second value).
- camera (the pos of the camera at each moment)
- player (the players current position)
- velocity (the player’s current velocity).
- accelerator (changes the player’s acceleration)
- wheel (the interval on which the wheel turns).
- steering (the direction in which the steering wheel and motion points).
- lives (the player’s current live count)
- lane-y (stores the positions and spacing of the road lanes)
- BOOST (holds the positionsof the BOOST icon)
- EXTRALIFE (holds the position of the EXTRALIFE icon).


## Controls
There are four controls:
- w
- a
- s
- d.

Pushing each control results in:
w sets the player’s acceleration to 1, increasing the players forward velocity.
s sets the player’s acceleration to -1, decreasing the player’s forward velocity.
a sets the player’s steering to -1, moving the player to the left.
d sets the player’s steering to 1, moving the player to the right.

When a control is released the player’s acceleration is set back to zero through ‘key-up’.

## UI and HUD

The game contains a minimalistic UI so as to avoid distraction or inconvenience to the player.

A steering wheel can be found in the left hand corner. It is set to turn a certain degrees depending on the value of the player’s steering and displays how far they are steering in either x-direction.

The score, lives, fps and speed string all appear in the top-left of the screen. 

- The score text converts the player’s distance travelled to metres.
- The speed is converted from pixels to metres to show the player’s y velocity in km/hr.
- The lives text displays how many lives the player has remaining from 1-5.
- The fps text shows the game’s current frame rate, the max of which can be adjusted in json to better fit each user’s device’s specs.

The three rectangles lining the top of the screen indicate the x co-ordinate of each special-item, showing the player where to move to if they want to obtain it.
Later iterations could potentially implement a speedometer to display the player's velocity.

## Camera. 
The camera looks down on the player and road in a 2-D system. The camera is set to follow the player’s movement:
 (set-gs-camera! game (pos 0 (- (pos-y (gs-player game)) SCENE.CAMERAHEIGHT)))
  game
).
All items (unless intended to stay on the screen at all times such as the score count or UI) must be placed in ‘draw’ relative to the camera, for example BOOST is placed with:

 (let (
    [xcam (pos-x (gs-camera game))]
    [ycam (pos-y (gs-camera game))])

(pos (- (pos-x (gs-BOOST game)) xcam) (- (pos-y (gs-BOOST game)) ycam)).

##Physics
The programme uses researched physical values to accurately describe the motion of the car on the road. The code accounts for any major forces which would have an effect on its motion:

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
(define friction (* mu CAR.MASS g)) ; N
(define rolling-resistance (* 0.015 CAR.MASS g)) ; N
(define traction (/ (* CAR.TORQUE CAR.DRIVERATIO) CAR.WHEELRADIUS)) ; N
(define (drag v) (* 0.5 CAR.Cd CAR.AREA (sqr v))) ; N

Netforce uses these quantities to model the total force acting on the car, which is added to the car’s general y-velocity to give ‘newyspeed’ which is its upwards velocity with all relevant external forces accounted for. (Note that newsfeed takes the max of 0 or yspeed + net force, so the velocity will never be negative and cause the car to reverse). Netforce makes it easier to track all forces at once.

In terms of collisions, ‘el’ determines how much energy is retained by the car, used in ‘out-of-bounds’, ‘touching’ and ‘touching-cars?’. It’s worth noting that in terms of collisions player enjoyment was heavily prioritised over making a realistic system where the player crashing results in a major loss of velocity which would make the game too difficult.

#Steering
The steering control the player’s movement in the x direction.
It is calculated with degrees and is made to model a realistic steering system.
The maximum steering angle is set to 30 degrees. 
‘steer-omega’ calculates the player’s angular velocity when given a value.
The ‘steer-wheel’ function controls how the wheel icon behaves. Its max is set to negative ‘steer-max’ and its minimum to the negative. All steering takes place on the interval [-1,1], so it can only rotate fully to the right or left, before it locks, never a full rotation.  
As previously mentioned in controls, pressing ‘a’ or ‘d’ will change the steering’s value to -1 or 1 respectively, and on the control’s release will reset to 0 ([pointing fully forward.

The wheel will snap-back when released. This mimics realistic steering and makes the mechanic more interactive for the player as they have to keep control of it. The following code snippet from ‘steer-wheel’ checks if the steering is equal to 0, (the steering controls have not been selected or have been released) and sets the wheel accordingly, or sets it to the steer value if a control is selected.

 `(if (= (gs-steering game) 0)
                  (cond [(> (gs-wheel game) 0) -1] [(< (gs-wheel game) 0) 1] [else 0]) ; Wheel snap-back
                  (gs-steering game))))))).

In draw, the wheel is set to rotate by the value stored in the gs multiplied by -9:

(rotate (* (gs-wheel game) -9) STEERINGWHEEL)`, so it can turn a maximum of 270 degrees.


In ‘TICK-physics’, the function passed to ‘tick’, the player’s movement in the x-plane is the conversion of ‘gs-wheel’ from m2p multiplied by delta (the change in its angular velocity). The steering motion is controlled directly by the wheel’s current numerical value, which will move between -1 and 1 depending on steering’s value (remember steering is what changes from the player input).

##Road
The road values are defined in ‘animation.rkt’.

The road itself is defined under ‘ROAD’ which creates an image of two yellow lines, a black road and the grass patches on either side of the road and uses beside to orientate them.  
‘ROAD.LANEIMAGES’ makes a list of n-1 lanes (as n lanes requires n-1 rows of broken white lines.
It then builds a list of stripes and gaps and sets them to be placed above each other with `apply above` by calculating how many stripes can fit on the road.
Modulo checks ensures every second stripe is hit by calculating the remainder.
If the remainder of SCENE.HEIGHT/ROAD.STRIPESPACING =0, the road section ends with a dotted line, otherwise just the road between lines.

`ROAD.LANEOFFSET` sets a new co-ordinate system for placing the roads relative to near the top left corner of the image as opposed to the image centre. It's down a bit to give overflow so if the road lanes move down the screen and there is a gap. No overflow means it teleports back to the tope of the screen.

`Road.left-lane-x


`construct-lanes` creates a list of positions for the lanes by calculating
This also makes it easier for the player to choose a different SCENE.WIDTH or SCENE.HEIGHT in json, as the lanes will adjust accordingly.

##Animation
All objects are placed by `draw` which is updated in tick.
‘draw-scene’ allows developers to pass two lists to ‘draw’, the first containing all images and the second with their corresponding positions.
Quasi-quotation is used so lists such as ‘ROAD.LANEIMAGES’ and ‘gs-cars’ can be passed directly into the draw-scene lists.
To use quasiquotation, @ a list and place a comment before each item, like so:
,@ROAD.LANEIMAGES.
`draw-scene` uses a fold so it must be ensured that corresponding lists contain the same amount of elements or an error will occur:

(define (draw-scene imgs posns) ; Draw scene from lists of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))

##Tick
The functions passed to tick are the following:
-(TICK-physics game delta)
-(TICK-animation game)
-(collisions-update game)
-(set-gs-t! game now)
  (when (= (modulo (round (* now 10)) 5) 0)
    (set-gs-fps! game (round (/ 1000 (* 1000 delta)))))
, where `now` is the time from initiation and delta is the time between frames.

Any functions which need to be updated constantly, such as object movement, fps updates and drawing.
If a new function like these is created it should be passed through here, although the current functions passed to tick already contain many functions within them, so it is best to see if a new function fits naturally in them first.

`(big-bang init [on-tick tick (/ 1 MAXFPS)] [to-draw draw] [on-key keydown] [on-release keyup] [stop-when game-over?])`
Where it aims to tick once per game.
##Big-Bang
This creates the universe and tells the programme what functions to run for any given moment on event.
Passing `tick` to `on-tick` tells the game to update that function every tick.
Passing `draw` to `to-draw`tells the game what function to use when drawing the universe.
`on-key` and `on-release` tell the game to use `keydown` or `keyup` respectively.
Passing `game-over?` to `stop-when` tells the universe when to terminate.

#json
The json file is used to allow players and developers to change important repeated numerical values with ease.
In this file the values of the map’s width and height, the maximum fps as well as the number, of AIs can be changed by simply altering the number.
If a developer were to decide to add another important repeated value, they should type it in json and use hash-ref to access it in the game, as can be seen in `header.rkt`:
(define SCENE.WIDTH (max(hash-ref (hash-ref config 'resolution) 'width) (+ ROAD.WIDTH 80))).
`configure` is defined in `header.rkt` to allow developers to reference the file.


##References 

Images:

Player: https://publicdomainvectors.org/en/free-clipart/Red-car-vector-art/2579.html
AI: 
-https://publicdomainvectors.org/en/free-clipart/Top-view-car-vector/2260.html
-https://publicdomainvectors.org/en/free-clipart/Vector-image-of-a-car/3123.html
-https://publicdomainvectors.org/en/free-clipart/Turquoise-racing-car-vector-drawing/9690.html
-https://publicdomainvectors.org/en/free-clipart/Purple-racing-car-vector-graphics/9689.html
-https://publicdomainvectors.org/en/free-clipart/Yellow-racing-car-vector-illustration/9691.html
-https://publicdomainvectors.org/en/free-clipart/Orange-racing-car-vector-image/9687.html
-https://publicdomainvectors.org/en/free-clipart/Black-car-vector-illustration/9676.html
-https://publicdomainvectors.org/en/free-clipart/Pink-car-top-view-vector-illustration/9657.html
-https://publicdomainvectors.org/en/free-clipart/Car-top-view/40462.html
-https://publicdomainvectors.org/en/free-clipart/Medical-van-top-view-vector-illustration/27093.html
-https://publicdomainvectors.org/en/free-clipart/Fire-emergency-truck-top-view-vector-image/27092.html
-https://publicdomainvectors.org/en/free-clipart/Vector-clip-art-of-top-view-of-man-on-motorbike/27380.html

Items:
BOOST: https://publicdomainvectors.org/en/free-clipart/Vector-illustration-of-fuel-canister/17859.html
EXTRALIFE: https://publicdomainvectors.org/en/free-clipart/Car-wheel-vector-image/5122.html
Steering wheel: https://publicdomainvectors.org/en/free-clipart/Driving-wheel-vector-image/7352.html

Jack:
-https://drive.google.com/file/d/1-yiF2Pq-OgJaTXsMAQbIckoDzGINz26O/view
-https://www.gamedevs.org/uploads/grand-theft-auto.pdf
-https://connect-prd-cdn.unity.com/20201215/83f3733d-3146-42de-8a69-f461d6662eb1/Game-Design-Document-Template.pdf
-https://5years.doomworld.com/doombible/doombible.pdf ;All of the above were referenced as examples and templates when writing the developer documentation.
-https://app.smartdraw.com/editor.aspx?credID=-108485678&depoId=78161746&flags=128 ;Used to draw the flowchart in this document.
-https://youtu.be/fBf90zHMrR4
-https://youtu.be/9T5H8CYaurI
-https://docs.racket-lang.org/reference/pairs.html#%28def._%28%28lib._racket%2Flist..rkt%29._partition%29%29
-https://docs.racket-lang.org/guide/lambda.html?version=9.3
-https://docs.racket-lang.org/reference/let.html?version=9.3#%28form._%28%28quote._~23~25kernel%29._let-values%29%29
-https://docs.racket-lang.org/reference/define-struct.html?version=9.3#%28form._%28%28lib._racket%2Fprivate%2Fbase..rkt%29._struct%29%29
-https://htdp.org