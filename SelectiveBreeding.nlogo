globals [
  world-timer
  surviving-rats
  surviving-signs
  enable-wrapping?
  number-of-previous-food-sources
  animation-timer
  generation
  follow-sign-enabled?
  spots-enabled?
  signs-enabled?
  global-energy-limit
]

; What is this code for?

; The netlogo code below will generate a number of rats
; that will try to find food.
; This model is meant to be a generational model
; concerning variables such as liklihood of dropping
; helpful signs and having the correct range adjustments (angle of wiggle)

; There will be a ranking system that ranks the signs per generation
; The ranking system will, also, apply to the rats

; https://en.wikipedia.org/wiki/Behavioural_genetics
; - interesting add the absence of traits

breed [ signs sign ]
breed [ rats rat ]
breed [ food-sources food-source ]

patches-own [
  spot-type
  toxic?
  gradient
]

signs-own [
  x-mem
  y-mem
  votes
  creator
]

rats-own [
  wiggle-deviation     ;; the range of possible angle deviation
  likelihood-to-drop   ;; the probability of dropping a sign every tick
  sign-deviation       ;; the range of possible angle deviation
  probability-of-lying ;; the probability of lying about the direction of the food source
  sign-energy

  location-of-xsign    ;; x-coordinate of the food source
  location-of-ysign    ;; y-coordinate of the food source

  found-sign?          ;; indicator for having found a sign
  trigger-location-x   ;;
  trigger-location-y   ;;

  found-food?          ;; indicator for having found food
  survived?            ;; indicator for surviving rats
  heading-out?         ;;
  can-drop-flag?       ;;
  the-sign-that-helped ;;
  number-eaten         ;;
  viewed-sign-color
  own-sign
]


; Reports the number of surviving rats
to-report count-rats-feed
  report (count rats with [ survived? = true ])
end

; Creates a random shift in wiggle, sign placement, etc
;   users can influence the desired outcome

to-report random-wiggle
  report (wiggle-preference + 5 - random 10)
end

to-report random-likely
  report (likelihood-preference + 5 - random 10)
end

to-report random-sign-dev
  report (sign-preference + 5 - random 10)
end

to-report random-lying
  report (lying-preference + 5 - random 10)
end

to configure-default-rat
    let maxturning 90
    let range-of-turning-angle range-of-max-turning-angle
    set wiggle-deviation (range-of-turning-angle / 2 - random range-of-turning-angle) + maxturning ; range of possible turn (degrees)
    set likelihood-to-drop random 5 ; chance of dropping a sign (%)
    set sign-deviation random 45    ; range of deviation of a sign (%)
    set probability-of-lying random 10 ; probability of deciding to lie

    set location-of-xsign 0
    set location-of-ysign 0
    set sign-energy global-energy-limit

    set found-sign? false
    set trigger-location-x 0
    set trigger-location-y 0

    set found-food? false ;; possibly give a review
    set survived? false
    set heading-out? false
    set can-drop-flag? false
    set the-sign-that-helped nobody
    set number-eaten 0
    set viewed-sign-color blue
    set own-sign nobody
end

to select-a-location
  move-to one-of patches with [ pcolor = black ]
end

to generate-rats [ number ]
  create-rats number [
    configure-default-rat
    select-a-location
    set color gray
    set shape "default"
    set size 4
  ]
end

to reproduction-of-rats [ number wig-dev likely sign-dev prob-lie ]
  create-rats number [
    set wiggle-deviation adjust-degrees (wig-dev + random-wiggle)         ;; adjust wiggle-deviation
    set likelihood-to-drop adjust-percentage (likely + random-likely)     ;; adjust probability to drop a sign
    set sign-deviation adjust-degrees (sign-dev + random-sign-dev)        ;; adjust the degree error on sign placement
    set probability-of-lying adjust-percentage (prob-lie + random-lying)  ;; adjust probability of lying

    set location-of-xsign 0
    set location-of-ysign 0
    set trigger-location-x 0
    set trigger-location-y 0
    set sign-energy ( random 5 - 10 ) + global-energy-limit

    set found-food? false ;; possibly give a review
    set found-sign? false
    set survived? false
    set number-eaten 0
    set the-sign-that-helped nobody
    set own-sign nobody
    select-a-location
    set color blue
    set shape "default"
    set size 5
  ]
end

to draw-radius-bound
  ;ask patches in-radius starting-radius  [set pcolor scale-color red 1.8 0 10 ]
  ask patches in-radius (starting-radius * (.75)) [set pcolor scale-color green 1.8 0 10 ]
end

to generate-food [ num ]
  ask patches [ set pcolor black ]
  if any? food-sources [
    ask food-sources [ draw-radius-bound ]
  ]
  let cap 100
  if count food-sources < cap [
    let difference cap - count food-sources
    let incr-num 0
    ifelse difference < num
      [ set incr-num cap - count food-sources ]
      [ set incr-num num ]
    create-food-sources incr-num [
        setxy (0 + (40 - random 80)) (0 + (40 - random 80))
        set   color orange
        set   size  4
        let   xcore xcor
        let   ycore ycor
        draw-radius-bound
        set   shape "square" ]]
end

to generate-spots
  ask patches [ set toxic? false ]
  if spots-enabled? [
    ask n-of 100 patches with [ neighbors with [ toxic? = true ] = no-patches ] [ set toxic? true set pcolor green ]
  ]
end

to initialize
  ask rats [ set the-sign-that-helped nobody set shape "default" ]
  set number-of-previous-food-sources 0
  set enable-wrapping? true
  set animation-timer 20
  set follow-sign-enabled? true
  set spots-enabled? false
  set signs-enabled? true
  set global-energy-limit 12
end

to-report extract-number-eaten [ one-rat ]
  let num-eaten 0
  ask one-rat [ set num-eaten number-eaten ]
  report num-eaten
end

to-report extract-wiggle-deviation [ one-rat ]
  let wiggle-angle 0
  ask one-rat [ set wiggle-angle wiggle-deviation ]
  report wiggle-angle
end

to-report extract-likelihood-deviation [ one-rat ]
  let tmp 0
  ask one-rat [ set tmp likelihood-to-drop ]
  report tmp
end

to-report extract-lying-deviation [ one-rat ]
  let tmp 0
  ask one-rat [ set tmp probability-of-lying ]
  report tmp
end

to setup
  clear-all
  random-seed 2301
  set generation 0
  initialize
  generate-food 10
  generate-spots
  generate-rats number-of-rats

  ask one-of rats [ pen-down ]
  reset-ticks
end

to wiggle [ deviation ]
  left random deviation
  right random deviation
  move-with-collision
end

to alternate-topology
  __change-topology enable-wrapping? enable-wrapping?
  set enable-wrapping? not enable-wrapping?
end

to alternate-sign-following
  set follow-sign-enabled? not follow-sign-enabled?
end

to move-with-collision
  let patch-destination patch-ahead 1
  let patch-color blue
  ifelse patch-destination != nobody [
    ask patch-destination [ set patch-color pcolor ]
    if patch-color != green [ fd 1 ]
  ] [ left random 360 ]
end

to run-around
  wiggle wiggle-deviation
  if signs in-cone 3 60 != no-turtles
    [ ask one-of signs in-cone 3 60 [
        ;if creator != 0 [
        ;  ask creator [ set number-eaten number-eaten + 1 ]
        ;]
      ]
    ] ;; what direction are you facing
  move-with-collision
end

;; lambdas can indicate traits and behaviors

to-report update-rat-state
  report [ ->
      set number-eaten number-eaten + 1 ;; need a way to display eating
      set found-food? true ;; should not eat any more
      set found-sign? false
      set survived? true
      set can-drop-flag? true
      set color white
  ]
end

to eat-if-you-can
  if any? (food-sources in-cone 5 60) and found-food? = false
    [ ask one-of food-sources in-cone 5 60 [ die ]
       run update-rat-state
    ] ;; find sign or travel outside a radius
end

to update-orientation-with-sign
  if not any? (food-sources in-cone (starting-radius * (.75)) 60)
    [ set found-food? false
      set color gray
      set found-sign? false ]
end

to thank-the-sign ; find that sign that helped you
  ;; how do you store that information
  if the-sign-that-helped != nobody [
    set color pink
    face the-sign-that-helped
  ]
  run-around
end

to-report extract-likely [ one-rat ]
  let return-variable 0
  ask one-rat [ set return-variable likelihood-to-drop ]
  report return-variable
end

to-report extract-sign-dev [ one-rat ]
  let return-variable 0
  ask one-rat [ set return-variable sign-deviation ]
  report return-variable
end

to-report extract-lies [ one-rat ]
  let return-variable 0
  ask one-rat [ set return-variable probability-of-lying ]
  report return-variable
end

;; setting up the next-generation
;; This should have a list of top surviving members

to readjust-wiggle-deviation
   ifelse wiggle-deviation > 0 and wiggle-deviation < 170 [
     set wiggle-deviation adjust-degrees (wiggle-deviation + (wiggle-preference + random 20 - 10))
   ] [
     set wiggle-deviation adjust-degrees wiggle-deviation
   ]
end

to readjust-likelihood
   ifelse likelihood-to-drop > 0 and likelihood-to-drop < 90 [
     set likelihood-to-drop adjust-percentage (likelihood-to-drop + (likelihood-preference + random 20 - 10))
   ] [
     set likelihood-to-drop adjust-percentage likelihood-to-drop
   ]
end

to regenerate-world
   generate-food 10
   generate-spots

   ask rats with [ survived? = false ] [ die ]
   if rats = no-turtles [ stop ] ;; generate-rats 5

   ask rats [ ;; deviations of themselves
     readjust-wiggle-deviation
     readjust-likelihood
     set number-eaten 0

     move-to one-of patches with [ pcolor = black ]
     while [ food-sources in-radius starting-radius != no-turtles ] [
       setxy random-xcor random-ycor
     ]
     set found-food? false
     set found-sign? false
     set sign-energy global-energy-limit
     set survived? false
     set can-drop-flag? false
     set own-sign nobody
   ]

   while [ count rats < number-of-rats ] [
     let survivor one-of rats with [ found-food? = true ]
     if survivor != no-turtles [ set survivor one-of rats ]
     reproduction-of-rats 1 (adjust-degrees extract-wiggle-deviation survivor)
                         (adjust-percentage extract-likely survivor)
                         (adjust-degrees extract-sign-dev survivor)
                         (adjust-percentage extract-lies survivor)
   ]

   clear-drawing
   ask rats [ pen-up ]
   ask min-one-of rats [ wiggle-deviation ] [ pen-down ]
   ask max-one-of rats [ wiggle-deviation ] [ pen-down ]
   ask rats [ set color gray ]
   ask signs [ die ]
end

to-report adjust-degrees [ value ]
  if value < 0 [ report 0 ]
  if value > 180 [ report 180 ]
  report value
end

to-report adjust-percentage [ value ]
  if value < 0 [ report 0 ]
  if value > 100 [ report 100 ]
  report value
end

to global-tick ; the generational clock
  set number-of-previous-food-sources count food-sources
  ifelse world-timer = 500 [
    set generation generation + 1
    set surviving-rats count rats with [ survived? = true ]
    set surviving-signs count signs
    set world-timer 0
    ask patches [ set pcolor black ]
    regenerate-world
  ]
  [ set world-timer world-timer + 1 ]
  tick
end

to-report report-generation
  report generation
end

to generate-flags-if-possible
  if count rats > 3 [
    ask rats with [ sign-energy < 5 ] [ die ]
  ]
  if any? (rats with [ can-drop-flag? = true ]) and signs-enabled? [ ;; it keeps generating triangles
        ask rats with [ can-drop-flag? = true ] [
        if likelihood-to-drop > random 100 [
        let probability-lying probability-of-lying
        if any? food-sources [
          set sign-energy sign-energy - 2
          hatch-signs 1 [
              set shape "arrow" set color white set size 3
              set creator myself
              let specified-food food-sources
              let direction-x [ xcor ] of one-of specified-food
              let direction-y [ ycor ] of one-of specified-food

              left random [ sign-deviation ] of myself
              right random [ sign-deviation ] of myself
              setxy direction-x direction-y

              ifelse probability-lying > random 100 [
                  set color red
                  facexy random-xcor random-ycor
              ] [ facexy direction-x direction-y
                  set color yellow ]]]]]]
end

to food-viewed-instruction
  if follow-sign-enabled? [
    (ifelse
        (viewed-sign-color = red)    [ facexy random-xcor random-ycor ]
        (viewed-sign-color = yellow) [ face one-of food-sources ])
  ]
end

to food-instructions
  (ifelse (found-sign? and not found-food? and any? food-sources)
            [ food-viewed-instruction
              run-around
              set color green ]
          (found-sign? and not found-food?) [ run-around ]
          true  [ run-around ])
end

to sign-encounter ;; the rats can influence themselves
  let sign-range 7
  if any? signs in-radius sign-range and own-sign = nobody
    [ set found-sign? true
      set color orange
      ifelse any? signs in-radius sign-range with [ color = red ]
        [ set viewed-sign-color red ]
        [ set viewed-sign-color yellow ]
    ]
end

to eating-animation
  if number-of-previous-food-sources > count food-sources [
    set animation-timer 0
  ]
  if animation-timer != 20 [
    if animation-timer = 0 [
      create-turtles 1 [ set shape "circle" set color magenta setxy 0 0 set size 4 facexy 0 100 ]
    ]
    ask turtles with [ shape = "circle" ] [ fd 1 ]
    if animation-timer = 19 [
      ask turtles with [ shape = "circle" ] [ die ]
    ]
    set animation-timer animation-timer + 1
  ]
end

to move-rats
  ask rats [
    ifelse not found-food?
      [ food-instructions ]
      [ thank-the-sign ]
    update-orientation-with-sign
    eat-if-you-can               ;; if you find food eat it, then update that you found it
    sign-encounter
  ]
  eating-animation
end

to go ;; go will start the process for the rats
  if not any? rats [ stop ]
  move-rats
  generate-flags-if-possible
  global-tick
end

to test
  create-rats 1 [ configure-default-rat setxy 0 0 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
250
10
863
624
-1
-1
3.01
1
10
1
1
1
0
1
1
1
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
10
10
81
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
80
10
167
43
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
165
10
228
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
895
235
1295
375
number-of-signs
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 0.01 0 -16777216 true "" "plot surviving-signs"

SLIDER
10
55
187
88
wiggle-preference
wiggle-preference
-10
10
0.0
1
1
NIL
HORIZONTAL

PLOT
895
10
1300
233
Maximum Turning Angle
NIL
NIL
0.0
360.0
0.0
10.0
true
false
"" ""
PENS
"max-turn" 0.1 2 -2674135 true "" "plot extract-wiggle-deviation max-one-of rats [ wiggle-deviation ]"
"min-turn" 0.1 2 -13345367 true "" "plot extract-wiggle-deviation min-one-of rats [ wiggle-deviation ]"

SLIDER
10
85
185
118
likelihood-preference
likelihood-preference
-10
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
10
115
185
148
sign-preference
sign-preference
-10
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
10
145
185
178
lying-preference
lying-preference
-10
10
-3.0
1
1
NIL
HORIZONTAL

PLOT
10
290
210
440
Fed Rats
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot surviving-rats"

SLIDER
10
180
184
213
number-of-rats
number-of-rats
10
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
10
215
184
248
starting-radius
starting-radius
5
max-pxcor - 10
36.0
1
1
NIL
HORIZONTAL

BUTTON
10
440
157
473
Toggle Topology
alternate-topology
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
10
545
167
602
NIL
report-generation
17
1
14

BUTTON
10
470
192
503
Toggle Sign Following
set signs-enabled? not signs-enabled?
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
895
380
1300
520
Probability of Placing a Sign
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -11033397 true "" "plot extract-likelihood-deviation max-one-of rats [ likelihood-to-drop ]"
"pen-1" 1.0 0 -7858858 true "" "plot extract-likelihood-deviation min-one-of rats [ likelihood-to-drop ]"

PLOT
895
520
1300
655
Likelihood of Lying
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -817084 true "" "plot extract-lying-deviation max-one-of rats [ probability-of-lying ]"
"pen-1" 1.0 0 -10899396 true "" "plot extract-lying-deviation min-one-of rats [ probability-of-lying ]"

BUTTON
10
500
160
533
Toggle Obstacles
set spots-enabled? not spots-enabled?\nif spots-enabled? [ generate-spots ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
250
185
283
range-of-max-turning-angle
range-of-max-turning-angle
0
70
31.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

The Behavioral Evolution model is a selective breeding case study on how desirable
traits are inherited and can be manipulated to skew future generations. This is often
observed in animal breeding and farming. When certain behaviors are probabilistic, this
can, also, be passed onto organisms each generation.

Food is placed randomly within a 10 block radius, offering various blocks for the rat to start. Once the food is placed, the rats are randomly spawned outside a certain radius from the food source. Once the stage is set, the rats search for the food source using
their in-built traits.

There are many ways of approaches to finding the food source. One approach is can zigzaging in a straight line, widening their view and increasing their chance of finding the food-source. Another approach is search within an ever growing circle, eventually
finding the food source. Along with the variety of strategies, the environment can
change, transforming into a tourus or an enclosed space.

What would happen if after several generations of rats evolving from a tourus environment
is suddenly dropped in an enclosed environment. In some cases, the rats may die off because of the lack of variety or they might bounce back with enough variation.

The goal of the model is to demonstrate how selective breeding can be both beneficial and harmful.

There is one additional feature of the system, which adds the additions of signs. The signs are a collaborative trait assists other rats in finding the food source.

Can you think of a trait that would best feed the rats?


## HOW IT WORKS

The rats do not know where each food source is stored, which are placed in the center of the board. They, also, keep track of the likelihood of creating signs and the angle deviation for walking. Once the food source is found, the rat does not eat another piece until it is outside a specified radius.

To walk, the rats randomly select it's deviation based on their angle of deviation, which is inherited each generation.

To drop a flag, a rat must have found and eaten a food source. The drop rate is determined through an internal probability included in each rat.

In addition to dropping a flag, the signs accurracy and overall truthfulenss is determined through :
- The likelihood to lie
- the sign's accuracy

## HOW TO USE IT

Initial settings:
- wiggle-preference : a rat's maximum possible angle deviation
- likelihood-preference : a rat's probability of dropping a sign
- sign-preference : a rat's maximum possible sign angle deviation
- lying-preference : a rat's probability of dropping a misleading sign

The setup button will set the initial conditions. The go button will run the simulation, and the "go once" button will run the simulation for just one step, allowing you to watch what happens in more detail.

Other settings:
- hungry-chance: The probability of any thinking philosopher becoming hungry at any step.
- full-chance: The probability of any eating philosopher becoming full at any step.
- cooperation?: If off, the philosophers will use a naive strategy to acquire their forks; if on, they'll use a more sophisticated strategy. See HOW IT WORKS above.

Plots:
- Feed Rats: plots the amount of spaghetti each philosopher has consumed (based on how many time steps she has spent in the eating state).
- number-of-food-source: plots the number of food sources remaining over time.
- number-of-signs : plots the max number of signs each generation
- wiggle-deviation : plots the maximum and minimum wiggle deviation each generation

## THINGS TO NOTICE

Play with different configurations of wiggle-preference, likelihood-preference, sign-preference, and lying-preference and different numbers of rats.  See how different combinations stress the system in different ways.

What settings reduce the rats likelihood to survive?  (You may want to use the speed slider to fast forward the graphics so you can do longer runs more quickly.)

Notice how, although the system works well under certain circumstances, more stressful circumstances may expose a weakness.  This demonstrates the importance of "stress testing" when assessing the scalability of a system, particularly in the presence of concurrency.

## THINGS TO TRY

Experiment with the likelihood of sharing signs or leaving misleading signs. See if you can find a situation where there is a striking contrast between the behaviors of the cooperating rats and the naive rats.

Try running the system for a long time in a variety of different configurations.  Does it ever seem to perform well at first, but eventually die off? What about vice versa?  What do you think this shows about the value of "longevity testing" when assessing the stability and performance of a concurrent system?

## EXTENDING THE MODEL

Try to think of a different strategy for the rats, then implement it and see how well it works!  You will probably want to make use of marks, so remember that they are not visible unless cooperation is enabled; you may wish to change this.  Can you come up with a simpler strategy than the one we demonstrate?
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
