# HEDEHOG LICENSE

## Contents
- Concept Statement
- Genre
- Target Audience
- Scope
- Language and Device
- Modules
- Game Termination
- Score
- ITEMS
- Lives
- AI
- Difficulty
- Structs
- Collisions
- Controls
- UI and HUD
- Camera
- Physics
- Steering
- Road
- Animation
- Tick
- Big-Bang
- Sound
- json
- Miscellaneous
- References

## Concept Statement
This is an explosive 2-D vertical scroller which sees the player avoid other vehicles while weaving through traffic to try and get as high a score as possible. The player must ensure the clock does not reach 0 or the game will end. Power-ups can be obtained along the way which make each run unique and unpredictable. The game incorporates realistic steering and increasing difficulty as the player's score increases.

## Genre
This game is a single-player, retro, 2-D scroller, with fast-paced racing.

## Target Audience
This game can be enjoyed by players of any age, it avoids violence or brutality which makes it suitable for younger audiences, but its retro style and simplistic control-system can also appeal to an older generation not looking to play a game which requires major time commitments.

## Scope
This game a timed scroller if the which sees the player develop enough skill with the mechanics to beat the clock.
The game contains a number of AI which can be easily adjusted by players or developers, and their collisions with player's are modelled with real world physics.
The road and lane systems form the template for how the AI move, and the lane numbers, scene height, and scene width are also easily adjusted. There is only one map for player's to use.
The timing system is used to give players an extra challenge on top of avoiding traffic.
Realistic physical quantities and models are used to describe the motion of the car along the road.
A steering system is in place to give the player a more immersive feel and the steering wheel icon displays the steering direction at any given moment.
There are two power-ups, BOOST and EXTRATIME, which affect the player's velocity and the time they have to reach the next k milestone.
A minor sound system is implemented but was used as a late experiment to show what features could be developed in the game should someone wish to create further iterations.
The game was made with a close deadline in mind so multiplayer and multi-level design were never seen as realistic targets, although they would be relatively easy to implement by following the foundations our code lays out.

## Language and Device
The game is written on ‘Racket’ in Racket’s native language (accessed by #lang racket) and can be used on PC, laptops or tablets with an additional keyboard accessory, through racket software. 
Porting to other devices would not be too difficult, and should any future developers wish to do so they should mainly reference the ‘keydown’ and ‘key-up’ functions as well as adjust the display format (see section 'json' of this document).

## Modules
There are 6 modules in total stored within the project's folder. The game is run from `main.rkt`. The other five files can be found in the `dep` folder. Developers should use the following key to decide which folder to reference when making changes:
-`main.rkt`: runs the game, holds the initial game-state, holds the controls for movement, contains the ``tick` and `big-bang` functions, as well as any code for the title and death sequence.
-`AI.rkt`: creates the list of AI positions as well as the list of their image indexes. Holds the lane positions which AIs are places at. The AI's images can be changed here.
-`animation.rkt`: any definitions and functions involved in creating and placing the road and road markings can be found and adjusted here. All item and player images are stored here. The `draw` function is exported from this file, which places everything.
-`physics.rkt`: contains all physical definitions and the function which decides how these forces affect the player's motion. The steering and wheel functions can be found here, the physical bounds set for the player as well as adjusting how the camera is updated every tick.
-`collisions.rkt`: Any functions which define how objects interact with each other by touching are found here (including any items), as well as the functions which recycle and update the positions of the AI. 
-`header.rkt`: All structs are defined in this file as well as any definitions which are required in multiple files without creating circular dependencies. Any definitions imported from `json` are also stored here (more details on `json` further down`). Some short sound-files are also used in functions within this module.

## Game Termination
(See lines 44-66 and lines 96-99 in 'main.rkt`).
The game can end in three ways: 
-The player clicks the red stop button in the game pop-up window, prompting racket to stop running the programme.
-The player loses all of their lives and the programme stops running.
-The countdown reaches zero before the player reaches the next km mark or gets to an EXTRATIME item .
There are two functions which prompt termination: `tick` and `exit?`.
`tick` checks if the player runs out of lives or the countdown (referred to as `deadline` in the programme), reaches 0. When this function is called is called the player moves to up and to the right and is set to rotate depending on the `spin` value stored in the gs.
It will also prompt the fail screen to appear, (further discussed in UI and HUD). The  countdown is reset to the moment of termination. If the lives or countdown are greater than zero, the game will begin by starting to update all of its relevant gameplay functions in `tick`.

## Score
The player’s score is shown in the top left. It is directly proportional to the vertical distance travelled by the player in metres and can only be increased by moving further. It can be decreased when the player hits a car from behind with a velocity less than that car's, causing it to move backwards, thus decreasing the score.

## ITEMS
There are two items which the player can obtain: BOOST and EXTRATIME.

The BOOST icon is denoted by a fuel can.
When the player comes within 60 units in the x direction and 90 in the y direction of this item, it increases their velocity by negative 200 units in the y-direction.(reference the `touching?` function, lines 8-12 in `collisions-update.rkt`).
The item serves as a power-up in the beginning to build up speed more efficiently, but may also serve as an obstacle to the player if they are in close proximity of an AI as it will propel them into it.

The EXTRATIME icon is denoted by a stopwatch.
The `touching` function used for `BOOST` is also used here. This item adds a given amount of time to the countdown timer, meaning player's have better chance to outrun the clock.

Both items spawn at random positions on initialisation, determined by `interval`, which calculates a random position that is not out of bounds on the road. It is calculated using road dimension definitions from `header`, so if a developer changes the road dimensions they should not worry about going through other modules to adjust every dimension.

When the player moves past the items their position is adjusted proportional to the player’s velocity (see `behind?`, lines 15-16, and `spawn-distance`, lines 51-56 in `collisions-update.rkt`).
When the player touches the items, they will respawn a random distance away from the player. BOOST will spawn at least 2000 units away and at most 3000 (+ (random 1000) 2000), while EXTRATIME spawns between 10000 and 15000 units away, as it is objectively much more valuable to the player.

## Lives
The player starts the game with three lives. Lives can only be lost, never gained.
Lives can be lost in two ways. The first is when the player hits the outermost yellow line on either side of the screen, i.e tries to go out of bounds.
The second way is when the player collides with an NPC. These events will further be discussed in the collisions section of this document.

## AI
The AI are initially assigned 1 random lane position. The `make-car-pos' function (see lines 29-41 in `AI.rkt`) assigns each position an x co-ordinate for the centre of a random lane, by choosing a random number from 0 to `ROAD.LANES -1`. For example, if 0 is the random number selected on the first call, the first car is placed in row 1, if it is 3 the car is placed in the fourth row etc. A list is created using accumulative recursion until the number of elements reaches the number of desired AI. Again the distances for where the cars are placed are defined in `header.rkt` so a developer will not have to worry about updating any of the AI placing functions.


`make-cars-pos` uses y-offset to track how many AI have been placed in each lane. Whenever an AI is placed in a lane it is placed at least 700 units from the last AI (`base-split`) plus some random quantity `randy` (placed max 1200 from last car and min 700). This is done by using `list-increment` to add  1 to the 'no./lane` (number of cars per lane) which is randomly selected. Thus the lane which is selected places it at a vertical distance (* n base-split) (n being the number of times that lane has been selected and the number of cars in the lane) away from the starting point, with `randy` added on. This approach ensures cars will not tend to one side and there will never be a fully clear path for players for a long duration of time.


`x-offset' places the cars at a random x co-ordinate in the lane interval (a bit less than plus or minus the width of each lane from the centre). This ensures players can not simply drive between lanes to avoid cars because the AI moving in a straight line.


### Image Indexing

The AI's images can be found in the `npc` subfolder in the project's images folder. They are labelled as n.png where n is a number from 1-12.

A hash table is made as `AI.images` and each image is stored as an index.

This means that calling index 4 will give `3.png'. `for/list` then creates the list where each element is the corresponding index in the hash-table, (see `AI.images` line 10 in `AI.rkt`). `string-append` is also used so that Racket can reference the image through `bitmap/file`, by appending whatever number is being called between "img/npc/" and ".png". (this can be seen in lines 9-12 in ‘AI.rkt’)

Accumulative recursion is also used to randomly select and create a list of images large enough to correspond to the number of positions generated by 'AI.count'.

Previous images don’t need to be tracked and don't have to be unique in the list, for both a convenient and realistic approach. 

`AI.cars` is then passed to the initial game state and stores these lists of positions, images, npc-speeds and assigned lanes by using `car-maker`, which takes a pos, speed, image and lane to create a car which is stored.

The cars are passed to `draw`. If the player has traveled over 50m (see `AI.HEADSTART` line 58 in `header.rkt`), `map (lambda (car))` is used to extract the positions relative to the camera, and `(map (lambda (i) (hash-ref AI.images (car-index i))) (gs-cars game)) empty)` to extract the list of images (see lines 78 and 112-117 of `animation.rkt`).

### AI Movement and Interactions

The cars argument of the game state stores all of the car positions, speeds  their image index and the lane they are assigned to once they are generated.


Within the collisions-update function (lines 45-137 in ‘collisions-update.rkt’), the function ‘update-cars’ checks that cars arent too far ahead or too far behind and then updates them like normal. If the player is moving faster than a car and the car is more than 300 m behind the player, it is recycled, using ‘recycle’ function (lines 61 -71). Similarly, if the NPC is moving faster than the player and it is more than a `SCENE.HEIGHT` ahead of the player, it is recycled.


If a car is neither too far ahead nor behind, its position is updated based on its velocity and it is checked to be colliding with the player, using the absolute value of the distance between their positions. If colliding, coefficient of restitution (0.7, as defined in `header.rkt`) is applied to the player and the player loses a life and is jolted away from the NPC. Player and NPC speeds are updated, and using the ‘normalize’ function, the NPC’s speed gradually increases to its original. 


‘Update-cars’ is recursively called for all NPC cars, finally updating all the cars’ speeds and is ran within ‘collisions-update’ in ticking function starting as soon as the player has traveled over 100m.


### Image Indexing
The AI's images can be found in the `npc` subfolder in the project's images folder. They are labelled as n.png where n is a number from 1-12.
A hash table is made as `AI.images` and each image is stored as an index.
This means that calling index 4 will give `3.png'. `for/list` then creates the list where each element is the corresponding index in the hash-table, (see `AI.images` line 10 in `AI.rkt`). `string-append` is also used so that Racket can reference the image through `bitmap/file`, by appending whatever number is being called between "img/npc/" and ".png".

Accumulative recursion is also  used to randomly selecting and create a list of images large enough to correspond to the number of positions generated by 'AI.count'.
Previous images don’t need to be tracked and don't have to be unique in the list, for both a convenient and realistic approach. 
`make-car-images` (see lines 38-41 of `AI.rkt`), uses 'cons' to add a randomly referenced image index to the list up until it reaches the desired amount of elements.  

`AI.cars` is then passed to the initial game state and stores these lists of positions, images and npc-speeds by using `car-maker`, which takes a pos, speed and image to create a car which is stored in the list it creates.

The cars are passed to `draw` using 
`map (lambda (car))` to extract the positions relative to the camera, and `@(map car-index (gs-cars game))` to extract the list of images (see lines 76 and 103-106 of `animation.rkt`).

`AI.cars` stores a list of the car-structs and is used in init to set `gs-cars` to that list of all AI cars so that it can be mutated in other functions.

## Difficulty
The game's difficulty depends on the countdown time given to a player. This can be changed in `init` in `main.rkt`.

The countdown  adds a high level of difficulty to the game. `timeout` (see lines 61-66 in `main.rkt` is used to determines what value the time should be at any given moment (it is updated every time `tick` is called). When the player travels a km in the game the countdown is reset. The `deadline` (what the countdown is defined as in-game) has the remaining time from the last kilometre added on to its reset value, and the game-state which stores `km` adds 1 onto the stored value, so that the next milestone is checked against the next km. For example, if the player passes 5km, the stored value adds 1 so the next km checked for is 6km.

The AI's speed also grows with the player's velocity (see `speed` line 25-26 of `AI.rkt`). This is built into the `car` struct, so their speed

## Structs 
(See lines 9-15 `header.rkt`).
The game uses four structs:
-pos
-car
-gs.

The pos struct holds an x and y co-ordinate for each item, which makes items more convenient to place (accessed by (pos (pos-x__) (pos-y__)).)
The car struct holds a pos, a speed, a lane and an index (the index of its image in the list of images), which can be accessed by car-pos, car-speed, car-lane and car-image.
The gs (game-state) struct is a mutable structure which holds:
-t (the time from initialisation which is updated every frame)
-fps (the games current frames-per-second value)
-deadline (countdown for player to reach the next km milestone)
-km (the current km being checked for a milestone)
-camera (the pos of the camera at each moment)
-player (the players current position)
-velocity (the player’s current velocity)
-accelerator (the player’s acceleration, lies on the interval [-1,1])
-spin (rotate of the player in degrees)
-wheel (where the theoretical car wheels will point, in other words the direction the car steers in)
-steering (the value of the steering, lies on the interval [-1,1])
-lives (the player’s current life count)
-lane-y (stores the y values of the road objects and markings)
-BOOST (holds the position of the BOOST icon)
-EXTRATIME (holds the position of the EXTRATIME icon)

The `ts` function refers to the title state. It holds a heading, subheading, mouse-y and exit. `STATE.TITLESCREEN` is defined in `main` and is passed to `big-bang`. The heading simply refers to the text of the game's name upon initialisation. The subheading tells players to press `space` in order to initialise the game. `mouse-y` is initially set to 0, but the `mouse-event` function (which is only called in ts not gs) allows for the headings to appear again after the player has died. The road is also set to follow the mouse when the game is in ts, so that the player can scroll up the road between playthroughs. This state is used only between actual playthroughs.


## Collisions
There are multiple types collisions which can occur in this game. The first is between the player and either of the outermost two lanes. In this event the direction of their steering will be adjusted to point in the opposite direction of their horizontal velocity, it rebounds off the edge. (see `check-player-bounds` lines 46-56 of `physics.rkt`). The bounds are calculated using the road dimensions from 'header.rkt'.

To update the AI's stored values for a given event recursive functions should be used. Simply create a recursive function which takes the list of all cars `gs-cars`, states the base case and the condition to be checked. If the condition is true, cons a car with the new desired values onto that recursive function applied to the rest of the list.
For example: 
```
(define (add-gap x game)
  (if (empty? x)
      empty
      (cons
        (car
          (pos
            (pos-x (car-pos (first x)))
          (- (pos-y (car-pos (first x))) 20)
           (car-lane (first x))
             (car-index (first x))
        (add-gap (rest x) game))))
```
is a function which changes a cars vertical position by 20 units. (this function is no longer used in game but serves as an intuitive example). It retains the image, speed and lane of the car. By following this structure to create new functions for the AI. developers can easily change their values for any given circumstance.

If there is a collision between the player and an AI (see lines 97-119 in `collisions-update.rkt`), the coefficient of restitution for that collision is calculated by multiplying `CAR.E` (the general coefficient of restitution between player and cars), by the sum of the two vehicle's velocities in the vertical direction. `v-total` calculates the sum of the vehicle's velocities so that the Principle of Conservation of Momentum [PCM] can be used to calculate the AI's velocity after the collision. The same is also applied to their velocities in the horizontal direction:
```(/ (+ v-total e*v-relative) 2))```,
which can be visualised by mutating the PCM to give the car's velocity. 'Normalise' restricts the increase in the car's speed so that it does not continue at an accelerated rate indefinitely. It is assumed that all vehicles have the same mass for simplicity. The player's position also changes, it moves forward if its initial velocity is greater than the AI's, and backwards if it is less:
``` (set-gs-player! game (pos x (+ y (* 50 (if (< vy v-car) -1 1)))))```. The wheel is also calculated by subtracting the AI's horizontal co-ordinate from the player's, and 0.5 is used as a scalar so that the effect is dampened, especially if the car's are side by side.

If no collision is detected in the `update-cars` function, its vertical velocity is simply updated by subtracting the distance it travels between frames, ```[else (car
                (pos x-car (- y-car (* v-car delta)))``` which is found by multiplying its speed by the time between frames (s=vt).

The `ai-collisions` function checks for collisions between AI, to ensure that their positions will never overlap. It selects a car from the list it is provided and first checks if the cars are in the same lane, then if the selected car is below the other car it collides with. If the distance between the cars vertically is equal to or less than 150, all the conditions are met to assume the cars are colliding or are too close together. The other car's position is replaced in the list by returning a car with a greater speed so that it avoids the collision with the selected car nay speeding up. If the conditions are not met, the other car's values are returned as an element of the list.

The cars are also checked within the local function to see if they are eligible for recycling. If they are 300 units behind the player (vertically) 'recycle -1' is called on them, or `recycle 1` if their vertical positions exceed the `SCENE.HEIGHT`. The function is only called when the car's velocity is greater than the AIs, as otherwise the AI will catch up by itself. This function takes a car, and like the `make-car-pos` function (reference the AI section of this document for more) assign the car a new x co-ordinate which is a random position within a lane's width, and a y co-ordinate which places them behind or ahead of the player, depending on whether 1 or -1 is passed to `recycle` as an argument:
` (+ player-y (random 500) (* (+ SCENE.HEIGHT (if (< direction 0) player-v 0)) direction)))'. They are also given a speed, lane and image.

In `update-cars', `gs-cars` is set to a list which applies `update-cars` (collison with player occurrence or not) to a list which checks if cars are colliding with each other through 'ai-collisions'. If a developer wishes to add another function to alter the cars behaviour they should take time to consider if that function can pass naturally into this composite function;
```(set-gs-cars! game (update-cars (ai-collisions (reverse (gs-cars game) game) game) game delta))```.



## Controls
(See lines 69-89 in `main.rkt`).
There are six controls:
-w
-a
-s
-d
-space
-esc

Pushing each control results in:
w sets the player’s acceleration to 1, increasing the players forward velocity.
s sets the player’s acceleration to -1, decreasing the player’s forward velocity.
a sets the player’s steering to -1, moving the player to the left.
d sets the player’s steering to 1, moving the player to the right.

When a control is released the player’s acceleration is set back to zero through ‘key-up’.
The steering mechanics are further discussed later on in this document.

Space and esc only register inputs when the game is in ts. The player can press the space bar to start the game (as you have probably seen in the loading screen) and the esc button to exit the game. `exit` Is used to this. It simply checks if the game is in ts and prompts `stop-when` in `big-bang` if it is.

## UI and HUD
The game contains a minimalistic UI so as to avoid distraction or inconvenience to the player.

As previously mentioned, upon starting the game the player is shown a title screen, there is also a termination screen for when the player loses all of their lives or the countdown reaches 0, (see `timeout` and `tick` lines 44-66 in `main.rkt`).
A steering wheel can be found in the left hand corner. It is set to turn a certain degrees depending on the value of the player’s steering and displays how far they are pointing in the x-direction.

The score, fps, speed and distance until the next EXTRATIME all appear in the top-left of the screen. 

-The score text converts the player’s distance travelled to metres.
-The speed is converted from pixels to metres to show the player’s y velocity in km/hr.
-The lives text displays how many lives the player has remaining from 1-5.
-The fps text shows the game’s current frame rate, the max of which can be adjusted in json to better fit each user’s preferences.
-the distance between EXTRATIMNE simply subtracts the distance between the player and it. It takes the max value of 0 and the absolute value of that sum, so the distance will never be negative before the item respawns.

The three rectangles lining the top of the screen indicate the x co-ordinate of each special-item, showing the player where to move to if they want to obtain it.
Later iterations could potentially implement a speedometer to display the player's velocity.

## Camera. 
The camera looks down on the player and road in a 2-D system. The camera is set to follow the player’s movement by subtracting the height which the camera covers from the player's vertical displacement from the starting point (see lines 62-63 in `physics.rkt`).
 
All items (unless intended to stay on the screen at all times such as the score count or UI) must be placed in ‘draw’ relative to the camera, for example BOOST is placed with:

 (let (
    [xcam (pos-x (gs-camera game))]
    [ycam (pos-y (gs-camera game))])

(pos (- (pos-x (gs-BOOST game)) xcam) (- (pos-y (gs-BOOST game)) ycam)).

## Physics
The programme uses researched physical values to accurately describe the motion of the car on the road. The code accounts for any major forces which would have an effect on its motion such as car mass, torque, drive-ratio etc. (see lines 6-20 in `physics.rkt` for full details. Important definitions include `CAR.MAXSPEED`, `CAR.BRAKEPOWER`, , `rolling-resistance` and `traction`.


`netforce` (see lines 21-24 in `physics.rkt`) uses these quantities to model the total force acting on the car.

While the player is accelerating and has a velocity less than the maximum value, `rolling-resistance` and `drag` are subtracted from `traction` to give the `netforce`.
Otherwise, if the velocity is greater than 0 and there is no forward acceleration `rolling-resistance`, `drag` sum to give the negative `netforce`.
If the velocity is greater than 0 and the car is decelerating `CAR.BRAKEPOWER`, `rolling-resistance` and `drag` sum to give the negative total force.
If the velocity is <= 0, the negative product of the velocity and the car's mass, divided by the time between frames gives the `net force`. Delta is used so that the `netforce` value is updated every frame.

`newspeed` (see lines 51-59 in `physics.rkt`) is used to calculate a more accurate value of the car's velocity in the vertical plane when `netforce` has been accounted for.
By dividing `net force` by the car's mass we obtain the car's acceleration (by Newton's 2nd Law) and by multiplying by delta 9the time between frames) we get the change in acceleration, i.e the velocity. This is added on to the velocity the car gains from the player's input and allows for velocity to be subtracted when controls are released or idle, as newsfeed will be subtracted from the input velocity.

# Steering
(See lines 27-43 in `physics.rkt`).
The steering controls the player’s movement in the x direction.
It is calculated with degrees and is programmed to model a realistic steering system.

‘steer-omega’ calculates the player’s angular velocity based on the delta time.
The ‘steer-wheel’ function controls how the wheel icon behaves. Its max is set to negative ‘steer-max’ and its minimum to the positive. All steering takes place on the interval [-1,1], -1 being fully to the left and 1 being fully to the right.  

As previously mentioned in controls, pressing ‘a’ or ‘d’ will change the steering’s value to -1 or 1 respectively, and on the control’s release it will reset to 0 (pointing fully forward).

`steer-wheel` updates the rotation of the player's wheels. The locally defined `a` (see lines 29-43 of `physics.rkt`) refers to the angular acceleration of the player and it is updated between frames. This is calculated by adding `gs-wheel` (the current rotation) to `steer-omega` * direction.

`xspeed` uses `steer-wheel` to determine how far the player moves horizontally at any given moment, by letting it equal the player's angular velocity.

In draw, the wheel icon is set to rotate by the value stored in the gs multiplied by -9. Since `steer-max` is defined as 30 this means it can turn 270 degrees in either given direction from its starting point before locking.

## Road
(See lines 40-54 of `header.rkt` for rod dimension definitions)
(See lines 10-45 of `animation.rkt` for object definitions).

`ROAD.LANEIMAGES' makes a list of images for n-1 lanes (as 5 lanes would require 4 dotted lines to separate them) using `build-list`. The function divides the total map height by the spacing between the stripes to calculate how many stripes will fit on the road. It also checks to see if a gap between stripes or white stripe should be placed at the end of the list, using `modulo`. The list is created and the `above` is applied so that the objects represent a road structure.

`ROAD.LANEOFFSET` brings the co-ordinates of each object from its centre to near its top-left corner. It was decided not to use the top-left corner as our chosen method gives the lane overflow, so that the co-ordinate system allows it to move to the bottom of the screen until its upper left portion touches the bottom of the screen as opposed to its centre. Without it the lanes disappear too early.

'ROAD.left-lane-x' is used to reference the co-ordinates of where each lane should be put. It essentially calculates the position of where the first set of dotted lines should go so that the other lane co-ordinates are found by simply multiplying by whatever index the desired lane has. (for example the third set of dotted white lines is ```(* ROAD.left-lane-x 3)```.

`construct-lanes` is a function which takes the above three definitions and uses them to create a list of positions for the lane objects. The x co-ordinate multiplies ROAD.left-lane-x` and multiplies it by the index of the lane (as described above) and the y co-ordinate is set to the argument of the function plus the offset which gives it overflow.

`TICK-animation` is passed to tick so that the list of road object positions is updated constantly. It sets the `lane-y` argument of the function to update accordingly to the player's movement. It changes relative to the remainder of 

## Animation
(See lines 58-148 in `animation.rkt`).
All objects are placed by `draw` which is used in `big-bang`.
‘draw-scene’ allows developers to pass two lists to ‘draw’, the first containing all images and the second with their corresponding positions.
Quasi-quotation is used so lists such as ‘ROAD.LANEIMAGES’ and ‘gs-cars’ can be passed directly into the draw-scene lists.
To use quasiquotation, @ a list and place a comment before each item, like so:
`,@ROAD.LANEIMAGES`.
`draw-scene` uses a fold so it must be ensured that corresponding lists contain the same amount of elements or an error will occur:

(define (draw-scene imgs posns) ; Draw scene from lists of images and positions
  (foldl (lambda (img pos scene)
    (place-image img (pos-x pos) (pos-y pos) scene))
    SCENE.BG
    imgs
    posns))
See the camera section of this document for more information on placing items in `draw` relative to the camera.

## Tick
(See lines 32-59 in `main.rkt`).
The functions passed to tick are the following:
-`TICK-physcs`
-`TICK-animation`
-`collisions-update`
-the fps is constantly updated by setting `t` to `now` and updating `fps` relative to `delta`,
 where `now` is the time from initialisation and `delta` is the time between frames. This is done because in setting `t` to `now` every tick the last tick is timestamped, so when we subtract `t` from `now`, we get the time between ticks. Delta takes the minimum of the time between ticks or 0.1, which limits the fps to 10fps and updates the fps to the time between ticks:

Δt= now - t.

If a new function requiring constant updating like these is created it should be passed through here, although the current functions passed to tick already contain many functions within them, so it is best to see if a new function fits naturally in them first.
See the `game termination` section of this document for more information on how tick checks what title screen to display.

In `big-bang`, `tick` aims to run once every frame `[on-tick tick (/ 1 MAXFPS)]`.

## Big-Bang
(See line 68 of `main.rkt`).
This creates the universe and tells the programme what functions to run for any given moment on event.
Passing `tick` to `on-tick` tells the game to update that function every tick divided by the MAX.FPS, so the world is updated every frame as opposed to every tick.
Passing `draw` to `to-draw` tells the game what function to use when drawing the universe.
`on-key` and `on-release` tell the game to use `keydown` or `keyup` respectively.
Passing `exit?` to `stop-when` tells the universe when to terminate.

## Sound
There are a small number of sound files saved to the game (see lines 28-32 in `header.rkt`) and play when an event such as a collision or change in the player's acceleration occur. The audio system is not currently fleshed out as it was added as an extra feature close to this project's deadline but if a developer wanted to improve this system we recommend they download the `RSOUND` module as this is what we would use to improve this mechanic with additional time. It would allow for looping of sound files, potentially for a traffic sound or music to play at all times.

In the current version of the game, `play-sound` is used to extract the sound files from the project folder.

## JSON
The json file is used to allow players and developers to change important repeated numerical values with ease. 
Values which can be changed in `json`:
-max-fps
-resolution (size of game window)
-number of player lives
-traffic-density (amount of cars per 100 pixels) 
If a developer were to decide to add another important repeated value, they should type it in json and use hash-ref to access it in the game, as can be seen in `header.rkt`:
(define SCENE.WIDTH (max(hash-ref (hash-ref config 'resolution) 'width) (+ ROAD.WIDTH 80))).
`configure` is defined in `header.rkt` to allow developers to reference the file.

## Miscellaneous Definitions
-`list-increment` (see lines 29-35 in `header.rkt`):
This function is used to increase one element of a list per call of a function. It adds 1 to the element it lands on when i=0 and reconstructs the list with all elements unchanged except that one. If i doesn't equal 0, it calls on a shorter list with its index reduced by 1, so that in the next few passes it will reach 0 and perform the operation. This function is used to track which lanes the AI are placed in.
-`MAXFPS` (see line 38 in `header.rkt`):
This is the max fps which the game will use. It can be chosen by players or developers in the `json` file. This determines how often tick is called (1/MAXFPS) and what the value of `delta` (the time between frames) is across all modules.
-`AI.HEADSTART` (see line 58 of `header.rkt`):
This definition is used regarding car placement and ensures the cars don't spawn until the player has travelled 50m.
-`AI.count` (see line 59 of `header.rkt`):
This determines the size of the list of AI cars. It can be changed in `json` to increase or decrease difficulty depending on preferences.


## References 

Images:

Player: https://publicdomainvectors.org/en/free-clipart/Red-car-vector-art/2579.html
AI: 
- https://publicdomainvectors.org/en/free-clipart/Top-view-car-vector/2260.html
- https://publicdomainvectors.org/en/free-clipart/Vector-image-of-a-car/3123.html
- https://publicdomainvectors.org/en/free-clipart/Turquoise-racing-car-vector-drawing/9690.html
- https://publicdomainvectors.org/en/free-clipart/Purple-racing-car-vector-graphics/9689.html
- https://publicdomainvectors.org/en/free-clipart/Yellow-racing-car-vector-illustration/9691.html
- https://publicdomainvectors.org/en/free-clipart/Orange-racing-car-vector-image/9687.html
- https://publicdomainvectors.org/en/free-clipart/Black-car-vector-illustration/9676.html
- https://publicdomainvectors.org/en/free-clipart/Pink-car-top-view-vector-illustration/9657.html
- https://publicdomainvectors.org/en/free-clipart/Car-top-view/40462.html
- https://publicdomainvectors.org/en/free-clipart/Medical-van-top-view-vector-illustration/27093.html
- https://publicdomainvectors.org/en/free-clipart/Fire-emergency-truck-top-view-vector-image/27092.html
- https://publicdomainvectors.org/en/free-clipart/Vector-clip-art-of-top-view-of-man-on-motorbike/27380.html

Items:
BOOST: https://publicdomainvectors.org/en/free-clipart/Vector-illustration-of-fuel-canister/17859.html
EXTRATIME: https://publicdomainvectors.org/en/free-clipart/Stopwatch-without-shading-vector-image/11255.html
Steering wheel: https://publicdomainvectors.org/en/free-clipart/Driving-wheel-vector-image/7352.html

Code and Miscellaneous:
- https://drive.google.com/file/d/1-yiF2Pq-OgJaTXsMAQbIckoDzGINz26O/view
- https://www.gamedevs.org/uploads/grand-theft-auto.pdf
- https://connect-prd-cdn.unity.com/20201215/83f3733d-3146-42de-8a69-f461d6662eb1/Game-Design-Document-Template.pdf
- https://5years.doomworld.com/doombible/doombible.pdf ;All of the above were referenced as examples and templates when writing the developer documentation.
- https://app.smartdraw.com/editor.aspx?credID=-108485678&depoId=78161746&flags=128 ;Used to draw the flowchart in this document.
- https://youtu.be/fBf90zHMrR4
- https://youtu.be/9T5H8CYaurI
- https://docs.racket-lang.org/reference/pairs.html#%28def._%28%28lib._racket%2Flist..rkt%29._partition%29%29
- https://docs.racket-lang.org/guide/lambda.html?version=9.3
- https://docs.racket-lang.org/reference/let.html?version=9.3#%28form._%28%28quote._~23~25kernel%29._let-values%29%29
- https://docs.racket-lang.org/reference/define-struct.html?version=9.3#%28form._%28%28lib._racket%2Fprivate%2Fbase..rkt%29._struct%29%29
- https://htdp.org
- https://freesound.org/people/Logicogonist/sounds/807438/
- https://freesound.org/people/DigPro120/sounds/859910/
-https://freesound.org/people/roboroo/sounds/436786/
-0https://freesound.org/people/Paloma.SSSS/sounds/841370/ ; no sound fils contained any license restrictions
-audacity 4 used to edit sound files



