;==============================================================
;==============================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==============================================================


;--------------------------------------
;--------------------------------------
                * = $5400
;--------------------------------------

;   Initial Map Coordinates

;   x-coords of all units (pixel frame)
CorpsX          .byte 0,40,40,40,40,40,41,40,41,41,41,42,42,42,42,43
                .byte 43,43,41,40,40,41,41,42,42,42,40,41,42,41,42,42
                .byte 43,41,42,43,30,30,31,33,35,37,35,36,36,45,45,38
                .byte 45,31,45,45,32,45,45
;   RUSSIAN
                .byte 29,27,24,23,20,15,0,0,0,0,0,0,0,0,0,0
                .byte 21,21,30,30,39,38,23,19,34,34,31,27,33,41,40,39
                .byte 42,39,39,39,39,39,37,39,39,39,40,41,41,39,36,34
                .byte 32,35,30,28,25,29,32,33,26,21,29,0,28,21,21,21
                .byte 20,20,12,0,0,0,0,0,0,0,21,25,0,0,0,0
                .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,38,21
                .byte 12,20,21,20,15,21,20,19

;   y-coords of all units (pixel frame)
CorpsY          .byte 0,20,19,18,17,16,20,19,18,17,16,20,19,18,17,19
                .byte 18,17,23,22,21,21,22,22,23,24,15,14,13,15,14,12
                .byte 13,15,16,16,2,3,4,6,7,8,38,37,38,20,15,8
                .byte 16,1,20,19,1,17,18
;   RUSSIAN
                .byte 32,31,38,38,38,38,20,8,18,10,14,33,11,15,20,10
                .byte 28,27,14,13,28,28,31,24,22,21,34,6,37,24,23,23
                .byte 25,20,22,18,17,21,20,19,16,15,14,13,12,11,9,8
                .byte 6,9,4,2,6,14,22,36,23,8,33,28,30,20,28,33
                .byte 27,30,8,10,32,11,25,12,23,13,29,30,31,15,27,17
                .byte 25,11,23,19,21,33,28,13,26,10,29,35,27,15,30,22
                .byte 8,13,14,28,3,3,3,2

MusterStrength  .byte 0,203,205,192,199,184,136,127,150,129,136,109,72,70,81,131
                .byte 102,53,198,194,129,123,101,104,112,120,202,195,191,72,140,142
                .byte 119,111,122,77,97,96,92,125,131,106,112,104,101,210,97,98
                .byte 95,52,98,96,55,104,101
;   RUSSIAN
                .byte 100,103,110,101,92,103,105,107,111,88,117,84,109,89,105,93
                .byte 62,104,101,67,104,84,127,112,111,91,79,69,108,118,137,70
                .byte 85,130,91,131,71,86,75,90,123,124,151,128,88,77,79,80
                .byte 126,79,91,84,72,86,76,99,67,78,121,114,105,122,127,129
                .byte 105,111,112,127,119,89,108,113,105,94,103,97,108,110,111,96
                .byte 109,112,95,93,114,103,107,105,92,109,101,106,95,99,101,118
                .byte 106,112,104,185,108,94,102,98

CombatStrength  .fill 159

;   Two purposes for the SWAP table
;   Contains the unit type (infantry or armor) when the unit is place on the map
;   Once placed, swapped with the terrain type in which the unit occupies
SWAP            .byte 0,126,126,126,126,126,125,125,125,125,125,125,125,125,125,125
                .byte 125,125,126,126,125,125,125,125,125,125,126,126,126,126,125,125
                .byte 125,125,125,125,125,125,125,125,125,125,125,125,125,126,125,126
                .byte 125,125,125,125,125,125,126
;   RUSSIAN
                .byte 253,253,253,253,253,253,253,253,253,253,254,254,254,254,254,254
                .byte 254,253,253,254,253,254,253,253,253,254,253,253,253,253,253,254
                .byte 254,253,253,253,254,254,254,254,253,253,253,253,254,254,254,254
                .byte 253,254,254,254,253,253,253,253,253,253,253,253,253,253,253,253
                .byte 253,253,253,253,253,253,253,253,253,253,254,253,253,253,253,253
                .byte 253,253,253,253,254,254,254,253,254,253,254,254,253,254,253,253
                .byte 253,253,253,253,253,253,253,253

;   the turn in which the unit first enters the map
ArrivalTurn     .byte 255,0,255,0,0,0,0,0,0,0,0,255,255,255,255,255
                .byte 255,255,0,0,0,0,0,0,0,0,0,0,0,255,0,0
                .byte 0,0,255,255,0,0,0,0,0,0,0,0,255,2,255,2
                .byte 5,6,9,10,11,20,24
;   RUSSIAN
                .byte 4,5,7,9,11,13,7,12,8,10,10,14,15,16,18,7
                .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                .byte 0,0,0,0,1,1,1,1,1,2,2,2,3,3,4,4
                .byte 5,5,6,6,7,8,8,8,9,9,5,5,2,9,10,10
                .byte 6,11,5,17,2,11,20,21,22,23,24,26,28,30,2,3
                .byte 3,3,3,6,6,4,4,4

;   various words for messages
WordsTbl        .text "        "
                .text "SS      "
                .text "FINNISH "
                .text "RUMANIAN"
                .text "ITALIAN "
                .text "HUNGARAN"
                .text "MOUNTAIN"
                .text "GUARDS  "
                .text "INFANTRY"
                .text "TANK    "
                .text "CAVALRY "
                .text "PANZER  "
                .text "MILITIA "
                .text "SHOCK   "
                .text "PARATRP "
                .text "PZRGRNDR"
                .text "        "
                .text "JANUARY "
                .text "FEBRUARY"
                .text "MARCH   "
                .text "APRIL   "
                .text "MAY     "
                .text "JUNE    "
                .text "JULY    "
                .text "AUGUST  "
                .text "SEPTEMBR"
                .text "OCTOBER "
                .text "NOVEMBER"
                .text "DECEMBER"
                .text "CORPS   "
                .text "ARMY    "
                .text "MUSTER  "
                .text "COMBAT  "
                .text "STRENGTH"

;   codes for unit types
CorpType        .byte 0,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0
                .byte 0,$40,3,3,0,0,0,0,0,0,3,3,3,3,0,0
                .byte 0,0,0,0,$30,$30,$30,0,0,0,$20,$20,$20,3,0,$53
                .byte 0,$30,0,0,$40,0,7
;   RUSSIAN
                .byte 4,4,0,0,0,0,0,0,0,0,1,1,1,1,1,2
                .byte 1,0,0,2,0,1,0,0,0,1,4,0,4,0,0,1
                .byte 1,0,0,0,1,1,2,2,0,0,0,0,1,1,1,2
                .byte 0,1,2,2,0,4,0,4,0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0,0,0,$72,0,$70,$70,$70,$70
                .byte 0,0,0,0,$72,1,$71,$70,1,$70,1,1,0,0,0,0
                .byte 0,0,0,4,4,4,4,4

;   ID numbers of units
CorpNumber      .byte 0,24,39,46,47,57,5,6,7,8,9,12,13,20,42,43
                .byte 53,3,41,56,1,2,10,26,28,38,3,14,48,52,49,4
                .byte 17,29,44,55,1,2,4,11,30,54,2,4,6,40,27,1
                .byte 23,5,34,35,4,51,50
;   RUSSIAN
                .byte 7,11,41,42,43,44,45,46,47,48,9,13,14,15,16,7
                .byte 2,19,18,1,27,10,22,21,13,6,9,2,1,8,11,1
                .byte 7,3,4,10,5,8,3,6,5,6,12,26,3,4,11,5
                .byte 9,12,4,2,7,2,14,4,15,16,20,6,24,40,29,30
                .byte 31,32,33,37,43,49,50,52,54,55,1,34,1,2,3,4
                .byte 39,59,60,61,2,1,1,5,2,6,3,4,38,36,35,28
                .byte 25,23,17,8,10,3,5,6

;   HERE COME NUMBER CODES
HundredDigit    .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 1,1,1,1,1,1,1,1
                .byte 2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2
                .byte 2,2,2,2,2,2,2,2
TensDigit       .byte 0,0,0,0,0,0,0,0,0,0
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 3,3,3,3,3,3,3,3,3,3
                .byte 4,4,4,4,4,4,4,4,4,4
                .byte 5,5,5,5,5,5,5,5,5,5
                .byte 6,6,6,6,6,6,6,6,6,6
                .byte 7,7,7,7,7,7,7,7,7,7
                .byte 8,8,8,8,8,8,8,8,8,8
                .byte 9,9,9,9,9,9,9,9,9,9
                .byte 0,0,0,0,0,0,0,0,0,0
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 3,3,3,3,3,3,3,3,3,3
                .byte 4,4,4,4,4,4,4,4,4,4
                .byte 5,5,5,5,5,5,5,5,5,5
                .byte 6,6,6,6,6,6,6,6,6,6
                .byte 7,7,7,7,7,7,7,7,7,7
                .byte 8,8,8,8,8,8,8,8,8,8
                .byte 9,9,9,9,9,9,9,9,9,9
                .byte 0,0,0,0,0,0,0,0,0,0
                .byte 1,1,1,1,1,1,1,1,1,1
                .byte 2,2,2,2,2,2,2,2,2,2
                .byte 3,3,3,3,3,3,3,3,3,3
                .byte 4,4,4,4,4,4,4,4,4,4
                .byte 5,5,5,5,5,5
OnesDigit       .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5,6,7,8,9
                .byte 0,1,2,3,4,5

TxtTbl          .text "PLEASE ENTER YOUR ORDERS NOW    "
                .text "          GAME OVER             "
                .text "FIGURING MOVE; NO ORDERS ALLOWED"

DaysInMonth     .byte 0,31,28,31,30,31
                .byte 30,31,31,30,31,30,31

HowManyOrders   .fill 159               ; how many orders each unit has in queue
WhatOrders      .fill 159               ; what the orders are
WHORDH          .fill 159

;   Sound frequencies when order given
BEEPTB          .byte 30,40,50,60

;   table of error messages
ERRMSG          .text "    THAT IS A RUSSIAN UNIT!     "
                .text "   ONLY 8 ORDERS ARE ALLOWED!   "
                .text "  PLEASE WAIT FOR MALTAKREUZE!  "
                .text "   NO DIAGONAL MOVES ALLOWED!   "

;   Used for unit motion
XOFF            .byte 0,8,0,$F8         ; offsets for moving maltakreuze
YOFF            .byte $F8,0,8,0
MASKO           .byte 3,$0C,$30,$C0     ; mask values for decoding orders
XADD            .byte 0,1,0,$FF         ; offsets for moving arrow
YADD            .byte $FF,0,1,0

;   Monthly color used for trees
TreeColors      .byte $00
                .byte $12,$12,$12,$D2,$D8,$D6
                .byte $C4,$D4,$C2,$12,$12,$12

;   maltese cross stamp
MLTKRZ          .byte %00100100         ; ..#..#..
                .byte %00100100         ; ..#..#..
                .byte %11100111         ; ###..###
                .byte %00000000         ; ........
                .byte %00000000         ; ........
                .byte %11100111         ; ###..###
                .byte %00100100         ; ..#..#..
                .byte %00100100         ; ..#..#..

;--------------------------------------
;--------------------------------------
                * = $6000
;--------------------------------------
;   First comes 1024 bytes of new character set

                .include "FONTS.asm"

;
;   The display list goes here; it is 49 bytes long.
;
DisplayList     ;.byte AEMPTY8,AEMPTY8,AEMPTY8
                ;.byte $06+ADLI+ALMS                 ; big text
                ;    .addr L64E0
                ;.byte AEMPTY0+ADLI+AHSCR            ; blank line
                ;.byte AEMPTY0+ADLI+AHSCR            ; blank line

                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR     ; 9 map lines
                ;    .addr MAPWDW
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $652E
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $655E
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $658E
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $65BE
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $65EE
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $661E
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $664E
                ;.byte $07+ADLI+ALMS+AHSCR+AVSCR
                ;    .addr $667E
                ;.byte $07+ALMS+AHSCR                ; extra map line to accommodate fine scroll
                ;    .addr $66AE

                ;.byte AEMPTY0+ADLI+AHSCR    ; blank line
                ;.byte $02+ADLI+ALMS         ; text
                ;    .addr TXTWDW
                ;.byte $02                   ; text
                ;.byte AEMPTY0+ADLI+AHSCR    ; blank line
                ;.byte $02                   ; text
                ;.byte AEMPTY0+ADLI+AHSCR    ; blank line
                ;.byte AVB+AJMP
                ;    .addr DisplayList

ArrowTbl        .byte %00010000         ; ...#....
                .byte %00111000         ; ..###...
                .byte %01010100         ; .#.#.#..
                .byte %10010010         ; #..#..#.
                .byte %00010000         ; ...#....
                .byte %00010000         ; ...#....
                .byte %00010000         ; ...#....
                .byte %00010000         ; ...#....

                .byte %00001000         ; ....#...
                .byte %00000100         ; .....#..
                .byte %00000010         ; ......#.
                .byte %11111111         ; ########
                .byte %00000010         ; ......#.
                .byte %00000100         ; .....#..
                .byte %00001000         ; ....#...
                .byte %00000000         ; ........

                .byte %00010000         ; ...#....
                .byte %00010000         ; ...#....
                .byte %00010000         ; ...#....
                .byte %00010000         ; ...#....
                .byte %10010010         ; #..#..#.
                .byte %01010100         ; .#.#.#..
                .byte %00111000         ; ..###...
                .byte %00010000         ; ...#....

                .byte %00010000         ; ...#....
                .byte %00100000         ; ..#.....
                .byte %01000000         ; .#......
                .byte %11111111         ; ########
                .byte %01000000         ; .#......
                .byte %00100000         ; ..#.....      ; BUG: overflows into text buffer
                .byte %00010000         ; ...#....
                .byte %00000000         ; ........


;--------------------------------------
;--------------------------------------
                * = $6450
;--------------------------------------

            .enc "atari-screen"

TXTWDW          .text '    '
                .text '            EASTERN FRONT 1941          '
                .text '    '

                .text '    '
                .text '       COPYRIGHT 1981 CHRIS CRAWFORD    '
                .text '    '

                .text '    '
                .text '                                        '
                .text '    '

L64E0           .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00   ; top text
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00

            .enc "none"


;--------------------------------------
;--------------------------------------
MAPWDW          * = $64FF
;--------------------------------------

                .include "MAP.asm"


;   Decoding for joystick
STKTAB          .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,1
                .byte $FF,$FF,$FF,3,$FF,2,0,$FF

;   season codes
SSNCOD          .byte 40,40,40,20,0,0,0,0,0,20,40,40

;   Terrain cost table
TRNTAB          .byte 6,12,8,0,0,18,14,8,20,128
                .byte 4,8,6,0,0,18,13,6,16,128
                .byte 24,30,24,0,0,30,30,26,28,128
                .byte 30,30,30,0,0,30,30,30,30,128
                .byte 10,16,10,12,12,24,28,12,24,128
                .byte 6,10,8,8,8,24,28,8,20,128

;   Blocked movement paths - intraversible square pair coordinates
BHX1            .byte 40,39,38,36,35,34,22,15,15,14
                .byte 40,39,38,35,35,34,22,15,14,14,19,19
BHY1            .byte 35,35,35,33,36,36,4,7,7,8
                .byte 36,36,36,33,37,37,3,6,7,7,4,3
BHX2            .byte 40,39,38,35,35,34,22,15,14,14
                .byte 40,39,38,36,35,34,22,15,15,14,19,19
BHY2            .byte 36,36,36,33,37,37,3,6,7,7
                .byte 35,35,35,33,36,36,4,7,7,8,3,4

;   Turn at which the next order will be executed
EXEC            .fill 159,$00

            .end
