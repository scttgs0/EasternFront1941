;==============================================================
;==============================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==============================================================

; x-coordinates = range[45:0]   upper-left  = (45,38)
; y-coordinates = range[38:0]   lower-right = (0,0)

;finns at start
;   35,38   144,32  10,0    45-35=10    38-38=0
;   36,37   160,16   9,1    45-36=9     38-37=1

;russian at start
;   33,37   192,32  12,1    45-33=12    38-37=1
;   31,34   224,80  14,4    45-31=14    38-34=4

;   Initial Map Coordinates

;   x-coords of all units (pixel frame)
CorpsX          .byte 0     ; unused
                .byte 40,40,40,40,40,41,40,41,41,41,42,42,42,42,43
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
CorpsY          .byte 0     ; unused
                .byte 20,19,18,17,16,20,19,18,17,16,20,19,18,17,19
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

MusterStrength  .byte 0     ; unused
                .byte 203,205,192,199,184,136,127,150,129,136,109,72,70,81,131
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

CombatStrength  .fill 159,$00

;   Two purposes for the SWAP table
;   Contains the unit type (infantry or armor) when the unit is place on the map
;   Once placed, swapped with the terrain type in which the unit occupies
SWAP            .byte $00     ; unused
                .byte $3E,$3E,$3E,$3E,$3E,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D
                .byte $3D,$81,$3E,$3E,$3D,$3D,$3D,$3D,$3D,$3D,$3E,$3E,$3E,$3E,$3D,$3D
                .byte $3D,$3D,$3D,$3D,$82,$82,$82,$3D,$3D,$3D,$80,$80,$80,$3E,$3D,$3E
                .byte $3D,$82,$3D,$3D,$81,$3D,$3E
;   RUSSIAN
                .byte $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7E,$7E,$7E,$7E,$7E,$7E
                .byte $7E,$7D,$7D,$7E,$7D,$7E,$7D,$7D,$7D,$7E,$7D,$7D,$7D,$7D,$7D,$7E
                .byte $7E,$7D,$7D,$7D,$7E,$7E,$7E,$7E,$7D,$7D,$7D,$7D,$7E,$7E,$7E,$7E
                .byte $7D,$7E,$7E,$7E,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D
                .byte $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7E,$7D,$7D,$7D,$7D,$7D
                .byte $7D,$7D,$7D,$7D,$7E,$7E,$7E,$7D,$7E,$7D,$7E,$7E,$7D,$7E,$7D,$7D
                .byte $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D

;   the turn in which the unit first enters the map
ArrivalTurn     .byte 255     ; unused
                .byte 0,255,0,0,0,0,0,0,0,0,255,255,255,255,255
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

;   codes for unit types
CorpType        .byte 0     ; unused
                .byte 3,3,3,3,3,0,0,0,0,0,0,0,0,0,0
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
CorpNumber      .byte 0     ; unused
                .byte 24,39,46,47,57,5,6,7,8,9,12,13,20,42,43
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

;   various words for messages
WordsTbl        .text "        "    ;0
                .text "SS      "    ;1
                .text "FINNISH "    ;2
                .text "RUMANIAN"    ;3
                .text "ITALIAN "    ;4
                .text "HUNGARAN"    ;5
                .text "MOUNTAIN"    ;6
                .text "GUARDS  "    ;7
                .text "INFANTRY"    ;8
                .text "TANK    "    ;9
                .text "CAVALRY "    ;10
                .text "PANZER  "    ;11
                .text "MILITIA "    ;12
                .text "SHOCK   "    ;13
                .text "PARATRP "    ;14
                .text "PZRGRNDR"    ;15
                .text "        "    ;16
                .text "JANUARY "    ;17
                .text "FEBRUARY"    ;18
                .text "MARCH   "    ;19
                .text "APRIL   "    ;20
                .text "MAY     "    ;21
                .text "JUNE    "    ;22
                .text "JULY    "    ;23
                .text "AUGUST  "    ;24
                .text "SEPTEMBR"    ;25
                .text "OCTOBER "    ;26
                .text "NOVEMBER"    ;27
                .text "DECEMBER"    ;28
                .text "CORPS   "    ;29
                .text "ARMY    "    ;30
                .text "MUSTER  "    ;31
                .text "COMBAT  "    ;32
                .text "STRENGTH"    ;33

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

TxtTbl          .text "        ENTER YOUR ORDERS       "
                .text "            GAME OVER           "
                .text "FIGURING MOVE; NO ORDERS ALLOWED"

DaysInMonth     .byte 0,31,28,31,30,31
                .byte 30,31,31,30,31,30,31

HowManyOrders   .fill 159,$00           ; how many orders each unit has in queue
WhatOrders      .fill 159,$00           ; what the orders are
WHORDH          .fill 159,$00

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
                .align $1000
;--------------------------------------

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

;--------------------------------------
;--------------------------------------

BITTAB          .byte $C0,3,$C,$30
ROTARR          .byte 4,9,14,19,24
                .byte 3,8,13,18,23
                .byte 2,7,12,17,22
                .byte 1,6,11,16,21
                .byte 0,5,10,15,20

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; added for binary compatibility
OBJX            ;.fill 104
                .byte $03,$08,$0d,$12,$17,$02,$07,$0c,$11,$16,$01,$06,$0b,$10,$15,$00,$05,$0a,$0f,$14
                .fill 84
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;--------------------------------------
;--------------------------------------

NDX             .byte 0,1,2,3,4,9,14,19
                .byte 24,23,22,21,20,15,10,5
                .byte 6,7,8,13,18,17,16,11
YINC            .byte 1
XINC            .byte 0,$FF,0,1
OFFNC           .byte 1,1,1,1,1,1,2,2,1,0

;--------------------------------------
;--------------------------------------

JSTP            .byte 0,0,0,0,3,3,3,3
                .byte 2,2,2,2,1,1,1,0
                .byte 0,0,3,3,2,2,1,0
DEFNC           .byte 2,3,3,2,2,2,1,1,2,0

;--------------------------------------
;--------------------------------------

MOSCOW          .byte 0,0,0,0

                .byte $22,$50,$a6,$c2,$ca,$f0
                .BYTE $03,$4c,$ff,$70,$ee,$2e
                .byte $06,$ad,$2e,$06,$c9,$20

;--------------------------------------
;--------------------------------------

ZPVAL           .word $6400             ; display list address
                .word $0000             ; map address
                .byte $00               ; active corp
                .word $0122             ; cursor x
                .word $0230             ; cursor y

PSXVAL          .byte $E0               ; position x
                .word $0000             ; position y
                .byte $0038             ; screen cursor y
                .byte $0078             ; player-0 position
                .byte $D6               ; tree color
                .byte $10               ; earth color
                .byte $27               ; ice latitude
                .byte $40,$00,$01       ; season 1-3
                .byte $0F,$06,$29       ; day month year
                .byte $00,$01           ; BUTTON_FLAG[1st-press not occurred], BUTTON_MASK[prevent]

COLTAB          .byte $58,$DC,$2F,$00   ; color table
                .byte $6A,$0C,$94,$46,$B0

MPTS            .byte 20,10,10,10       ; 0=Moscow
MOSCX           .byte 20,33,20,6        ; 1=Leningrad
MOSCY           .byte 28,36,15,15       ; 2=Kharkov
                                        ; 3=Stalingrad
