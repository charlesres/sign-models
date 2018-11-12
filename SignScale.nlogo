globals [
  batch
  value
  homexcor
  homeycor
  max-grad
]

;;; Breeds : signals and people ;;;
breed [ signals signal ]
breed [ person people  ]

patches-own [
  nType
  sign
  grad
]

;;; Evolutionary

;; super rats

;; Variables [ factors ]
;; - The likelihood of dropping a sign is a random distribution for rat's deviation
;;     and can be passed down
;; - The freedom of range for dropping a sign wiggle 45 or 35 degrees

;; Environment [ outside effects ]
;; - Rating system for signs [ helps with voting for rats ]
;; - Food depletes
;; - Yelp review [ probability to do mislead ]
;;   * Having the animals review it by coming back

;; adding refreshing signs [ search to refresh signs ]
  ;; adding a reset timer option [X]
;; Idea : bad posts can endure more than good posts

;; highways for signs [ signs to home ] [ well, preserved roads ]
  ;; create a sign that points to the nearest sign

;; signs to signs [ making paths ]
  ;; making a path from a series of signs

;; paths that are being treaded
  ;; show the traffic of traveling

;; another utility rating [ how help ] [ rating system ]
  ;; add a rating system for good signs [ self-fixing / competitive ]

person-own [
  found-sign?
  found-home?
]

signals-own [
  signal-timer
  fxcor
  fycor
]

to setup
  clear-all
  ask patches [ set nType "non-toxic" ]
  ask patches with [ nType = "non-toxic" ] [ set grad 20 ]
  set max-grad 20
  reset-ticks
end

to set-people-default
  ask person [ set found-sign? false
               set found-home? false ]
end

to generate-world
  generate-environment
  generate-people
  set display-highlights? true
end

to generate-environment
  setup
  ask patches [ set pcolor black ]
  generate-toxic-spots
  generate-home-spot
end

to generate-toxic-spots ;; patches
  ;; create a list of random spots
  repeat number-of-toxic-spots [ ;; number-of-toxic-spots
    set batch (patches with [ nType = "non-toxic" ])
    ask one-of batch [
      if patches with [nType = "toxic"] in-radius 4 = no-patches [
      set nType "toxic"
      set pcolor green
      ask neighbors [ set nType "toxic" set pcolor green]
      ]
    ]
  ]
end

to generate-home-spot
  let ntPatches patches with [ nType = "non-toxic" ]
  ask one-of ntPatches with [ (abs pxcor < 5) and (abs pycor < 5) ]
                       [ set nType "home"        ;; pick one home patch
                         set pcolor cyan
			 set homexcor pxcor
			 set homeycor pycor ]
  ask patches with [ nType = "home" ] [          ;; generate home spots
    ask patches in-radius 3 [ set nType "home"   ;; update surrounding patches to be of type "home"
                              set pcolor cyan ]  ;; update their color
    ask patches in-radius 7 with [ nType = "toxic" ] [ set nType "non-toxic" set pcolor black ]
  ]
end

to generate-people
  create-person number-of-individuals [
    set color blue          ;; setting individuals to blue
    set size 4              ;; setting size to 4

    setxy random-xcor random-ycor ;; set location of individual
    let home-and-toxic-patches patches with [ nType = "toxic" or nType = "home" ]
    while [ home-and-toxic-patches in-radius 2 != no-patches ]
      [ setxy random-xcor random-ycor ]
  ]
  set-people-default
end

;; Start moving people
to random-walk
  let toxic? false

  left random wiggle-room right random wiggle-room ;; turn randomly
  ask patch-ahead 2 [ if nType = "toxic" [ set toxic? true ] ]
  ifelse toxic? [ ]
                [ forward 1 ]
end

to uphill-mod              ;; turtle procedure
  let toxic? false
  ask patch-ahead 2 [      ;; look ahead and check for toxic spots
     if nType = "toxic" [ set toxic? true ]
  ]
  ;; Was the patch ahead toxic
  ifelse toxic?
    [ left random 180 ]  ;; turn away from it [ no direction bias ]
    [ let p max-one-of neighbors with [ nType = "non-toxic" ] [ sign ]
      if p != nobody
        [ face p
	  fd 1 ]]
end

to reply-to-sign
end

to head-to-home  ;; turtle procedure
  if found-sign?
    [ uphill-mod ]
end

to head-to-direction ;; adjusts as you go
  let dirX 0 let dirY 0
  if signals in-radius 7 != no-turtles [
    ask one-of signals in-radius 7 [ set dirX xcor set dirY ycor]
  ]
  facexy homexcor homeycor
  random-walk
end

to home-instruction
  if not found-home? [
    ifelse not found-sign?
     [ head-to-home
       if (any? signals in-radius 3)
         [ set found-sign? true
           set color       yellow ]]
     [ head-to-direction ]
  ]
end

to people-walking ;; procedure for walking
   ask person [
     home-instruction
     random-walk
     ask patches with [ nType = "home" ] [
       ask person in-radius 1 [
         set found-home? true
	 set color orange
       ]
     ]
   ]
end

to recolor-patch
  set sign sign * (70 / 100)
;;  set pcolor scale-color red sign 0.1 5
end

to broadcast-normal
  ask person with [ found-sign? = true ] [
    set found-sign? false
  ]
end

;; Go towards other signs [ doesn't store location data ]
to set-orientation
  set size 4
  set shape "arrow"
  set signal-timer 200
end


to drop-a-sign-to-home [ xcoord ycoord ]
  create-signals 1 [ set xcor xcoord ;; location : x
                     set ycor ycoord ;; location : y
		     set color white
		     let lfxcor 0
		     let lfycor 0
		     ifelse count (signals in-radius 10) - 1 > 0
		     [
		       ask one-of signals in-radius 10 [ set lfxcor xcor set lfycor ycor ]
		       set color cyan
		     ]
		     [
		       ask one-of patches with [ nType = "home" ] [ set lfxcor pxcor set lfycor pycor ]
		       set color pink
		     ]
		     set fycor lfycor
		     set fxcor lfxcor
		     facexy fxcor fycor
		     set-orientation ]
end

;; what determines this
to drop-a-sign-to-sign [ xcoord ycoord ] ;; home coordinates
  create-signals 1 [ set xcor xcoord
                     set ycor ycoord
		     set color white
		     let lfxcor 0
		     let lfycor 0
		     if one-of signals in-radius 5 != no-turtles [ face one-of signals in-radius 5 ]
		     set fxcor lfxcor
		     set fycor lfycor
		     set-orientation ]
end

to randomly-drop-a-sign
  if random 180 < 2 [
    let xcoord 0
    let ycoord 0
    if one-of person with [ distance one-of patches with [ nType = "home" ] > 5 and color = orange ] != nobody
    [
      ask one-of person with
            [ distance one-of patches with [ nType = "home" ] > 5 and color = orange ]
         [ set xcoord xcor set ycoord ycor ];; set coordinates to the person that dropped you
      drop-a-sign-to-home xcoord ycoord
    ]
  ]
end

to people-finding-their-town
  ask one-of patches with [ nType = "home" ] [
    ask person in-radius 1 with [ found-sign? = false ] [
      set found-sign? true
    ]
  ]
end

to global-timer
  ask signals [ if person with [ color = orange ] in-radius 2 != no-turtles
                   [ set signal-timer signal-timer + 15 ]]
  ask signals [ if signal-timer <= 50  [ set color yellow ]
                if signal-timer <= 25  [ set color orange ]
		if signal-timer <= 10  [ set color red    ]
;;		if signal-timer >= 90  [ set color white  ]
	      ] ;; rating system
  ask signals [ if signal-timer = 0 [ die ] set signal-timer signal-timer - 1]
end

to go
  if not any? turtles [ stop ]
  if not any? person with [ color = blue or color = yellow] [ ask person [ set color blue set found-home? false set found-sign? false ] ]

  people-walking            ;; People running in a zigzag pattern
  people-finding-their-town ;; People looking for their town
  randomly-drop-a-sign      ;; People randomly running

  global-timer

  diffuse sign (50 / 100)
  if display-highlights?
   [ ask patches with [ nType = "non-toxic" ] [ recolor-patch ] ]
;;  color-road
  tick
end

to color-road
  ask patches with [ nType = "non-toxic" ] [
    if person with [ color = yellow ] in-radius 1 != no-turtles [
       set grad 0.90 * grad
       set pcolor scale-color black grad max-grad 0
    ]
  ]
end

to go-quarter
  repeat 250 [ go ]
end

to go-half
  repeat 500 [ go ]
end

to go-whole
  repeat 1000 [ go ]
end

@#$#@#$#@
GRAPHICS-WINDOW
262
10
908
657
-1
-1
6.32
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

SLIDER
34
157
206
190
number-of-individuals
number-of-individuals
0
100
71.0
1
1
NIL
HORIZONTAL

SLIDER
22
232
232
265
number-of-toxic-spots
number-of-toxic-spots
0
200
115.0
1
1
NIL
HORIZONTAL

SLIDER
35
193
207
226
wiggle-room
wiggle-room
0
90
60.0
1
1
NIL
HORIZONTAL

BUTTON
20
66
91
99
setup
generate-world
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
94
66
157
99
go
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
159
67
222
100
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
924
10
1328
183
num-of-finding-members
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
"default" 1.0 0 -16777216 true "" "plot count turtles with [ color = orange ]"

PLOT
927
190
1334
330
num-of-seeking-members
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
"default" 1.0 0 -16777216 true "" "plot count turtles with [ color = yellow ]"

SWITCH
62
329
248
362
display-highlights?
display-highlights?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
0
@#$#@#$#@
