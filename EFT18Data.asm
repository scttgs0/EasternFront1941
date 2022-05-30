;==============================================================
;==============================================================
;EFT VERSION 1.8D (DATA) 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==============================================================

;--------------------------------------
;--------------------------------------
                * = $5400
;--------------------------------------

;   Initial Map Coordinates
CorpsX          .byte 0,40,40,40,40,40,41,40,41,41,41,42,42,42,42,43
                .byte 43,43,41,40,40,41,41,42,42,42,40,41,42,41,42,42
                .byte 43,41,42,43,30,30,31,33,35,37,35,36,36,45,45,38
                .byte 45,31,45,45,32,45,45
;RUSSIAN
                .byte 29,27,24,23,20,15,0,0,0,0,0,0,0,0,0,0
                .byte 21,21,30,30,39,38,23,19,34,34,31,27,33,41,40,39
                .byte 42,39,39,39,39,39,37,39,39,39,40,41,41,39,36,34
                .byte 32,35,30,28,25,29,32,33,26,21,29,0,28,21,21,21
                .byte 20,20,12,0,0,0,0,0,0,0,21,25,0,0,0,0
                .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,38,21
                .byte 12,20,21,20,15,21,20,19
CorpsY          .byte 0,20,19,18,17,16,20,19,18,17,16,20,19,18,17,19
                .byte 18,17,23,22,21,21,22,22,23,24,15,14,13,15,14,12
                .byte 13,15,16,16,2,3,4,6,7,8,38,37,38,20,15,8
                .byte 16,1,20,19,1,17,18
;RUSSIAN
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
;RUSSIAN
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
;RUSSIAN
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
;RUSSIAN
                .byte 4,5,7,9,11,13,7,12,8,10,10,14,15,16,18,7
                .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                .byte 0,0,0,0,1,1,1,1,1,2,2,2,3,3,4,4
                .byte 5,5,6,6,7,8,8,8,9,9,5,5,2,9,10,10
                .byte 6,11,5,17,2,11,20,21,22,23,24,26,28,30,2,3
                .byte 3,3,3,6,6,4,4,4

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

CorpType        .byte 0,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0
                .byte 0,$40,3,3,0,0,0,0,0,0,3,3,3,3,0,0
                .byte 0,0,0,0,$30,$30,$30,0,0,0,$20,$20,$20,3,0,$53
                .byte 0,$30,0,0,$40,0,7
;RUSSIAN
                .byte 4,4,0,0,0,0,0,0,0,0,1,1,1,1,1,2
                .byte 1,0,0,2,0,1,0,0,0,1,4,0,4,0,0,1
                .byte 1,0,0,0,1,1,2,2,0,0,0,0,1,1,1,2
                .byte 0,1,2,2,0,4,0,4,0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0,0,0,$72,0,$70,$70,$70,$70
                .byte 0,0,0,0,$72,1,$71,$70,1,$70,1,1,0,0,0,0
                .byte 0,0,0,4,4,4,4,4

CorpNumber      .byte 0,24,39,46,47,57,5,6,7,8,9,12,13,20,42,43
                .byte 53,3,41,56,1,2,10,26,28,38,3,14,48,52,49,4
                .byte 17,29,44,55,1,2,4,11,30,54,2,4,6,40,27,1
                .byte 23,5,34,35,4,51,50
;RUSSIAN
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

HowManyOrders   .fill 159
WhatOrders      .fill 318

;   Sound frequencies when order given
BEEPTB          .byte 30,40,50,60

ERRMSG          .text "    THAT IS A RUSSIAN UNIT!     "
                .text "   ONLY 8 ORDERS ARE ALLOWED!   "
                .text "  PLEASE WAIT FOR MALTAKREUZE!  "
                .text "   NO DIAGONAL MOVES ALLOWED!   "

;   Used for unit motion
XOFF            .byte 0,8,0,$F8
YOFF            .byte $F8,0,8,0
MASKO           .byte 3,$0C,$30,$C0
XADD            .byte 0,1,0,$FF
YADD            .byte $FF,0,1,0

;   Monthly color used for trees
TreeColors      .byte 0,$12,$12,$12,$D2,$D8
                .byte $D6,$C4,$D4,$C2,$12,$12,$12

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
;First comes 1024 bytes of new character set

                .include "FONTS.asm"

;
;The display list goes here; it is 49 bytes long.
;
                .byte $70,$70,$70,$C6,$E0,$64,$90,$90,$F7
                .byte $FE,$64,$F7,$2E,$65,$F7,$5E,$65
                .byte $F7,$8E,$65,$F7,$BE,$65,$F7,$EE
                .byte $65,$F7,$1E,$66,$F7,$4E,$66,$F7
                .byte $7E,$66,$57,$AE,$66,$90,$C2,$50
                .byte $64,$02,$90,$02,$90,$41,$00,$64

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
                .byte %00100000         ; ..#.....
                .byte %00010000         ; ...#....
                .byte %00000000         ; ........


;--------------------------------------
;--------------------------------------
                * = $6450
;--------------------------------------
;This next area is reserved for the text window

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; added for binary compatibility
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $25,$21,$33,$34,$25,$32,$2e,$00,$26,$32,$2f,$2e,$34,$00,$11,$19
                .byte $14,$11,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$23,$2f,$30,$39,$32
                .byte $29,$27,$28,$34,$00,$11,$19,$18,$11,$00,$23,$28,$32,$29,$33,$00
                .byte $23,$32,$21,$37,$26,$2f,$32,$24,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;--------------------------------------
;--------------------------------------
TXTWDW          * = $64FF               ; BUG: differs from all other files
;--------------------------------------

;
;The map data goes here.
;
                .byte 127,127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,191,191,191,169,0,0,0
                .byte 0,0,0,0,0,180,191,191
                .byte 170,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,191,191,191,175,178,0,0
                .byte 0,181,182,184,183,182,179,187
                .byte 176,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,191,191,191,191,175,184,183
                .byte 185,191,191,177,176,71,157,155
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,191,191,191,191,191,177,172
                .byte 173,174,187,188,164,141,148,140
                .byte 0,0,0,0,0,0,0,0
                .byte 157,165,0,156,160,162,166,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,191,191,191,191,191,171,0
                .byte 0,0,186,178,152,142,149,1
                .byte 5,0,0,0,0,0,0,0
                .byte 148,145,161,154,0,0,146,159
                .byte 165,0,0,0,0,156,164,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,191,191,191,191,191,170,0
                .byte 0,0,180,170,147,140,150,2
                .byte 6,0,0,0,0,0,0,0
                .byte 151,0,0,0,0,0,0,156
                .byte 168,72,0,157,161,153,145,160
                .byte 165,0,0,0,0,0,0,127
                .byte 127,191,191,191,191,191,175,178
                .byte 0,0,0,176,149,139,151,3
                .byte 1,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,149
                .byte 145,160,159,155,0,0,0,73
                .byte 146,166,0,0,0,0,0,127
                .byte 127,191,191,191,191,191,191,169
                .byte 0,0,0,0,0,0,152,4
                .byte 3,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,157,154
                .byte 0,0,0,0,0,0,0,0
                .byte 0,149,0,0,0,0,0,127
                .byte 127,191,191,177,172,191,191,170
                .byte 72,0,0,0,0,0,148,0
                .byte 2,0,0,0,0,0,0,0
                .byte 2,0,0,0,0,0,150,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,144,162,159,167,0,0,127
                .byte 127,191,191,170,0,179,173,188
                .byte 159,160,165,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 1,0,0,0,0,0,151,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,156,153,0,0,127
                .byte 127,191,191,169,0,0,0,0
                .byte 0,0,143,164,0,0,0,0
                .byte 0,157,155,0,0,0,73,0
                .byte 0,0,74,0,0,156,153,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,149,0,0,0,127
                .byte 127,191,191,171,0,0,0,0
                .byte 0,0,0,144,161,166,0,0
                .byte 156,154,0,0,0,0,0,3
                .byte 6,0,0,0,0,152,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,147,0,0,0,127
                .byte 127,191,191,175,178,0,0,0
                .byte 0,0,0,0,0,145,162,163
                .byte 153,0,0,0,2,151,4,1
                .byte 2,158,163,161,159,155,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,150,0,0,0,127
                .byte 127,191,191,191,170,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,156,162,153,0,3
                .byte 4,148,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,156,154,0,0,0,127
                .byte 127,191,191,177,188,160,159,161
                .byte 164,0,0,0,2,6,5,0
                .byte 0,157,163,154,71,0,1,6
                .byte 0,147,0,0,152,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,151,74,0,0,0,127
                .byte 127,191,177,176,0,0,0,0
                .byte 145,162,0,1,4,3,1,0
                .byte 158,155,0,0,0,0,0,0
                .byte 0,0,0,0,151,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,148,0,0,0,0,127
                .byte 127,173,176,0,0,0,0,0
                .byte 0,0,0,2,6,74,0,140
                .byte 150,139,0,0,0,0,0,0
                .byte 0,0,0,0,143,162,167,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,158,155,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,0
                .byte 0,1,3,5,0,0,0,142
                .byte 144,165,141,0,0,0,0,0
                .byte 0,71,0,0,0,0,150,73
                .byte 0,0,0,0,0,0,0,0
                .byte 0,152,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,0
                .byte 2,6,0,0,0,0,141,139
                .byte 142,146,167,0,0,0,0,0
                .byte 0,0,0,0,0,0,145,165
                .byte 0,0,0,0,0,0,0,0
                .byte 0,150,0,0,0,0,0,127
                .byte 127,166,73,0,0,0,0,0
                .byte 5,4,0,0,139,140,142,141
                .byte 140,0,152,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,149
                .byte 0,0,0,0,0,0,0,0
                .byte 0,149,0,0,0,0,0,127
                .byte 127,146,165,0,0,0,0,0
                .byte 3,1,0,0,141,159,163,165
                .byte 142,139,148,0,0,0,0,0
                .byte 0,0,150,0,0,0,0,144
                .byte 161,164,0,0,0,0,0,0
                .byte 0,151,0,0,0,0,0,127
                .byte 127,0,143,167,0,0,0,3
                .byte 4,6,0,139,140,142,141,145
                .byte 160,166,151,0,0,0,0,0
                .byte 0,0,145,166,0,0,0,0
                .byte 0,146,166,0,0,0,0,0
                .byte 0,148,0,0,0,0,0,127
                .byte 127,0,0,149,0,0,0,2
                .byte 5,139,142,141,139,140,139,142
                .byte 140,146,168,0,0,0,0,0
                .byte 0,0,0,151,0,0,0,0
                .byte 0,0,143,163,159,161,160,166
                .byte 0,152,0,0,0,0,0,127
                .byte 127,0,156,154,0,0,0,0
                .byte 0,140,139,141,142,140,0,0
                .byte 0,139,148,0,0,0,0,0
                .byte 0,0,74,148,0,0,0,0
                .byte 0,0,0,0,0,0,0,147
                .byte 71,143,159,160,162,165,0,127
                .byte 127,153,151,0,0,0,0,0
                .byte 0,0,142,0,0,0,0,0
                .byte 0,71,149,0,0,0,0,0
                .byte 0,0,0,144,165,0,0,0
                .byte 0,0,0,0,0,0,0,149
                .byte 0,0,0,0,0,144,166,127
                .byte 127,1,6,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,143,156,161,0,0,0
                .byte 0,0,0,0,146,156,155,157
                .byte 154,156,160,0,0,0,0,148
                .byte 0,0,0,0,0,0,146,127
                .byte 127,2,5,3,4,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,0,0,145,155,158,0
                .byte 0,0,0,0,0,0,0,0
                .byte 0,0,145,157,158,0,152,150
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,1,5,6,3,0
                .byte 0,156,161,0,0,0,156,159
                .byte 0,0,0,0,0,0,144,154
                .byte 160,0,0,0,0,0,0,0
                .byte 0,0,0,153,162,155,151,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,4,3,1
                .byte 5,0,145,159,0,0,0,146
                .byte 157,158,0,0,0,0,0,0
                .byte 146,157,159,0,0,0,0,0
                .byte 0,0,152,151,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,2,4
                .byte 6,0,0,143,155,156,154,160
                .byte 0,143,154,161,0,0,0,0
                .byte 0,0,143,158,0,0,0,0
                .byte 0,153,150,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,1
                .byte 3,5,0,0,0,0,0,144
                .byte 158,0,0,145,160,0,0,0
                .byte 0,0,72,147,0,0,0,176
                .byte 165,188,73,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,0
                .byte 2,6,4,0,0,0,0,0
                .byte 146,161,0,0,144,159,0,0
                .byte 0,0,153,150,0,177,166,170
                .byte 178,174,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,0
                .byte 0,5,1,6,0,160,0,0
                .byte 0,143,159,0,0,146,158,0
                .byte 0,0,149,0,175,171,191,179
                .byte 173,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,0
                .byte 0,1,2,4,3,144,161,0
                .byte 0,0,145,160,73,0,147,0
                .byte 0,152,151,0,164,191,191,168
                .byte 180,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,0
                .byte 0,5,3,6,2,1,143,159
                .byte 0,0,0,146,186,165,187,166
                .byte 167,188,182,172,191,191,191,178
                .byte 174,0,74,152,154,157,156,159
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,4,5,1,5,2
                .byte 3,6,1,4,5,6,2,145
                .byte 158,0,0,176,170,191,191,191
                .byte 178,173,183,184,184,185,163,181
                .byte 153,157,155,150,0,0,0,148
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,5,3,6,4,1
                .byte 4,2,0,3,4,1,6,0
                .byte 146,186,167,171,191,191,191,191
                .byte 168,180,0,0,176,170,191,169
                .byte 187,166,167,180,0,0,0,0
                .byte 0,0,0,0,0,0,0,127
                .byte 127,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 177,172,191,191,191,191,191,191
                .byte 191,169,181,175,171,191,191,191
                .byte 191,191,191,169,165,181,5,4
                .byte 2,3,6,1,6,2,1,127
                .byte 127,0,0,0,0,0,0,0
                .byte 0,0,0,0,0,0,0,0
                .byte 164,191,191,191,191,191,191,191
                .byte 191,191,168,172,191,191,191,191
                .byte 191,191,191,191,191,168,166,167
                .byte 181,1,2,3,4,3,3,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127
                .byte 127,127,127,127,127,127,127,127,127

;   Decoding for joystick
STKTAB          .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,1
                .byte $FF,$FF,$FF,3,$FF,2,0,$FF

SSNCOD          .byte 40,40,40,20,0,0,0,0,0,20,40,40

;   Terrain table
TRNTAB          .byte 6,12,8,0,0,18,14,8,20,128
                .byte 4,8,6,0,0,18,13,6,16,128
                .byte 24,30,24,0,0,30,30,26,28,128
                .byte 30,30,30,0,0,30,30,30,30,128
                .byte 10,16,10,12,12,24,28,12,24,128
                .byte 6,10,8,8,8,24,28,8,20,128

;   Blocked movement paths
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

            .END
