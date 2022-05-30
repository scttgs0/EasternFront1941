;================================================================
;================================================================
;EFT VERSION 1.8C (COMBAT) 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;================================================================

;======================================
;Page zero RAM
;======================================

;
;These locations are for the mainline routines
;
CHUNKX          = $BE
CHUNKY          = $BF
CORPS           = $B4

;--------------------------------------
;--------------------------------------
                * = $C0
;--------------------------------------
MAPPTR          .word ?
ARMY            .byte ?
UNITNO          .byte ?
DEFNDR          .byte ?
TEMPR           .byte ?
TEMPZ           .byte ?
ACCLO           .byte ?
ACCHI           .byte ?
TURN            .byte ?
LAT             .byte ?
LONG            .byte ?
RFR             .byte ?
TRNTYP          .byte ?
SQVAL           .byte ?
;
;
CONSOL          = $D01F
AUDF1           = $D200
AUDC1           = $D201
RANDOM          = $D20A
NMIEN           = $D40E
;
;THESE VALUES ARE USED BY MAINLINE ROUTINE ONLY
;
EARTH           = $606
TRNCOD          = $62B

;--------------------------------------
;--------------------------------------
                * = $636
;--------------------------------------
SQX             .byte ?                 ; adjacent square
SQY             .byte ?

;--------------------------------------
;--------------------------------------
                * = $68E
;--------------------------------------
DELAY           .byte ?
HANDCP          .byte ?
TOTGS           .byte ?
TOTRS           .byte ?
OFR             .byte ?
HOMEDR          .byte ?
ZOC             .byte ?
TEMPQ           .byte ?
LLIM            .byte ?
VICTRY          .byte ?
;
;declarations of routines in other modules
;
INVERT          = $4D26
STALL           = $7200
TERR            = $7240
TERRB           = $7246
Y00             = $72DE
TERRTY          = $7369
DNUMBR          = $7BB2
JSTP            = $799C
DWORDS          = $79C0
SWITCH          = $79EF
DEFNC           = $79B4
OFFNC           = $7BF6
XINC            = $7BF2
YINC            = $7BF1


;--------------------------------------
;--------------------------------------
                * = $5400
;--------------------------------------
CorpsX          .fill 159               ; x-coords of all units (pixel frame)
CorpsY          .fill 159               ; y-coords of all units (pixel frame)
MusterStrength  .fill 159               ; muster strengths
CombatStrength  .fill 159               ; combat strengths
SWAP            .fill 159               ; terrain code underneath unit
ArrivalTurn     .fill 159               ; turn of arrival
WordsTbl        .fill 272               ; various words for messages
CorpType        .fill 159               ; codes for unit types
CorpNumber      .fill 159               ; ID numbers of units
HundredDigit    .fill 256               ; tables for displaying numbers (hundreds)
TensDigit       .fill 256               ; tens tables
OnesDigit       .fill 256               ; ones tables
TxtTbl          .fill 96                ; more text
DaysInMonth     .fill 13                ; table of month lengths
HowManyOrders   .fill 159               ; how many orders each unit has in queue
WhatOrders      .fill 159               ; what the orders are
WHORDH          .fill 159
BEEPTB          .fill 4                 ; table of beep tones
ERRMSG          .fill 128               ; table of error messages
XOFF            .fill 4                 ; offsets for moving maltakreuze
YOFF            .fill 4
MASKO           .fill 4                 ; mask values for decoding orders
XADD            .fill 4                 ; offsets for moving arrow
YADD            .fill 4
TreeColors      .fill 13                ; tree color table
MLTKRZ          .fill 8                 ; maltese cross shape
;
;RAM from $6000 to $6430 is taken up by
;character sets and the display list
;
;--------------------------------------
;--------------------------------------
                * = $6431
;--------------------------------------
ArrowTbl        .fill 32                ; arrow shapes

;--------------------------------------
;--------------------------------------
                * = $6450
;--------------------------------------

;--------------------------------------
;--------------------------------------
TXTWDW          * = $6CB1
;--------------------------------------
STKTAB          .fill 16                ; a joystick decoding table
SSNCOD          .fill 12                ; season codes
TRNTAB          .fill 60                ; terrain cost tables
BHX1            .fill 22                ; intraversible square pair coordinates
BHY1            .fill 22
BHX2            .fill 22
BHY2            .fill 22
EXEC            .fill 159               ; execution times
;

;--------------------------------------
;--------------------------------------
                * = $4ED8
;--------------------------------------
;
;combat routine
;
                LDA #$00
                STA VICTRY              ; clear victory flag
                LDX ARMY
                CPX #$2A                ;Finns can't attack
                BEQ A10
                CPX #$2B
                BNE A11
A10             RTS
A11             LDY UNITNO
                STY DEFNDR
                LDX DEFNDR              ; make combat graphics
                LDA SWAP,X
                PHA
                LDA #$FF                ; solid red square
                CPX #$37                ; Russian unit?
                BCS B1
                LDA #$7F                ; make it white for Germans
B1              STA SWAP,X
                STX CORPS
                LDA CorpsX,X
                STA CHUNKX
                LDA CorpsY,X
                STA CHUNKY
                JSR SWITCH
                LDY #$08
                LDX #$8F
LOOP78          STX AUDC1
                STY AUDF1
                JSR STALL
                TYA
                CLC
                ADC #$08
                TAY
                DEX
                CPX #$7F
                BNE LOOP78
;
;now replace original unit character
;
                JSR SWITCH
                LDX DEFNDR
                PLA
                STA SWAP,X
;
;
                JSR TERRTY              ;terrain in defender's square
                LDX DEFNC,Y             ; defensive bonus factor
                LDA CombatStrength,Y            ;defender's strength
                LSR A
Y15             DEX                     ; adjust for terrain
                BEQ Y16
                ROL A
                BCC Y15
                LDA #$FF
;
;now adjust for defender's motion
;
Y16             LDX HowManyOrders,Y
                BEQ DOBATL
                LSR A
;
;evaluate defender's strike
;
DOBATL          CMP RANDOM
                BCC ATAKR
                LDX ARMY
                DEC MusterStrength,X
                LDA CombatStrength,X
                SBC #$05
                STA CombatStrength,X
                BEQ Z28
                BCS Y24
Z28             JMP DEAD                ; attacker dies
Y24             JSR BRKCHK              ; attacker lives; does he break?
;
;evaluate attacker's strike
;
ATAKR           LDX ARMY
                LDA CorpsX,X
                STA LONG
                LDA CorpsY,X
                STA LAT
                JSR TERR
                JSR TERRTY
                LDA OFFNC,Y
                TAY
                LDX ARMY
                LDA CombatStrength,X
                DEY
                BEQ Y19
                LSR A                   ; river attack penalty
Y19             CMP RANDOM
                BCC A20
                LDX DEFNDR              ; attacker strikes defender
                DEC MusterStrength,X
                LDA CombatStrength,X
                SBC #$05
                STA CombatStrength,X
                BEQ Z29
                BCS Y25
Z29             JSR DEAD                ; defender dies
A20             JMP ENDCOM
Y25             JSR BRKCHK              ; does defender break?
                BCC A20
                LDY ARMY
                LDA WhatOrders,Y
                AND #$03
                TAY                     ; first retreat priority : away from attacker
                JSR RETRET
                BCC VICCOM              ; defender died
                BEQ Y27                 ; defender may retreat
                LDY #$01                ; second priority: east/west
                CPX #$37
                BCS Y28
                LDY #$03
Y28             JSR RETRET
                BCC VICCOM
                BEQ Y27
                LDY #$02                ; third priority: north
                JSR RETRET
                BCC VICCOM
                BEQ Y27
                LDY #$00                ; fourth priority: south
                JSR RETRET
                BCC VICCOM
                BEQ Y27
                LDY #$03                ; last priority: west/east
                CPX #$37
                BCS Y26
                LDY #$01
Y26             JSR RETRET
                BCC VICCOM
                BNE ENDCOM
Y27             STX CORPS               ; retreat the defender
                LDA CorpsX,X
                STA CHUNKX
                LDA CorpsY,X
                STA CHUNKY
                JSR SWITCH
                LDX CORPS
                LDA LAT
                STA CorpsY,X
                STA CHUNKY
                LDA LONG
                STA CorpsX,X
                STA CHUNKX
                JSR SWITCH
VICCOM          LDX ARMY
                STX CORPS
                LDA CorpsX,X
                STA CHUNKX
                LDA CorpsY,X
                STA CHUNKY
                LDA ACCLO               ;defender's coordinates
                STA LONG
                LDA ACCHI
                STA LAT
                LDA #$FF
                STA VICTRY
ENDCOM          LDX ARMY
                INC EXEC,X
                RTS
;
;Subroutines for combat
;input: X = ID # of defender. Y = proposed DIR of retreat
;output: C bit set if defender lives, clear if dies
;Z bit set if retreat open, clear if blocked
;
RETRET          LDA CorpsX,X
                CLC
                ADC XINC,Y
                STA LONG
                LDA CorpsY,X
                CLC
                ADC YINC,Y
                STA LAT
                JSR TERR                ; examine terrain
                JSR TERRTY
                LDX DEFNDR
                LDA UNITNO              ; anybody in this square?
                BNE Y22
                LDA TRNTYP              ; no
;
;check for bad ocean crossings
;
                CMP #$07                ; coastline?
                BCC Y41
                CMP #$09
                BEQ Y22
                LDY #$15
LOOP42          LDA LAT
                CMP BHY1,Y
                BNE Y43
                LDA LONG
                CMP BHX1,Y
                BNE Y43
                LDA CorpsX,X
                CMP BHX2,Y
                BNE Y43
                LDA CorpsY,X
                CMP BHY2,Y
                BEQ Y22
Y43             DEY
                BPL LOOP42
;
;any blocking ZOC's?
;
Y41             JSR CHKZOC
                LDX DEFNDR
                LDA ZOC
                CMP #$02
                BCS Y22                 ; no retreat into ZOC
                LDA #$00                ; retreat is possible
                SEC
                RTS
Y22             LDA CombatStrength,X            ; retreat not possible,extract penalty
                SEC
                SBC #$05
                STA CombatStrength,X
                BEQ Z27
                BCS Y23
Z27             JSR DEAD
                CLC
Y23             LDA #$FF
                RTS
;
;supply evaluation routine
;
                LDA ArrivalTurn,X
                CMP TURN
                BEQ Z86
                BCC Z86
                RTS
Z86             LDA #$18
                CPX #$37
                BCS A13
                LDA #$18
                LDY EARTH
                CPY #$02                ; mud?
                BEQ A12
                CPY #$0A                ; snow?
                BNE A13
                LDA CorpsX,X            ; this discourages gung-ho corps
                ASL A                   ; double distance
                ASL A
                ADC #$4A
                CMP RANDOM
                BCC A12
                LDA #$10                ; harder to get supplies in winter
A13             STA ACCLO
                LDY #$01                ; Russians go east
                CPX #$37
                BCS Z80
                LDY #$03                ; Germans go west
Z80             STY HOMEDR
                LDA CorpsX,X
                STA LONG
                LDA CorpsY,X
                STA LAT
                LDA #$00
                STA RFR
LOOP91          LDA LONG
                STA SQX
                LDA LAT
                STA SQY
LOOP90          LDA SQX
                CLC
                ADC XINC,Y
                STA LONG
                LDA SQY
                CLC
                ADC YINC,Y
                STA LAT
                JSR CHKZOC
                CPX #$37
                BCC A80
                JSR TERRB
                LDA TRNCOD
                CMP #$BF
                BEQ A77
A80             LDA ZOC
                CMP #$02
                BCC Z81
                INC RFR
A77             INC RFR
                LDA RFR
                CMP ACCLO
                BCC Z84
A12             LSR CombatStrength,X
                BNE A50
                JMP DEAD
A50             RTS
Z84             LDA RANDOM
                AND #$02
                TAY
                JMP LOOP90
Z81             LDY HOMEDR
                LDA LONG
                CPY #$01
                BNE Z85
                CMP #$FF
                BNE LOOP91
                INC MusterStrength,X            ; Russian replacements
                INC MusterStrength,X
                RTS
Z85             CMP #$2E
                BNE LOOP91
                RTS
;
;routine to check for zone of control
;
CHKZOC          LDA #$00
                STA ZOC
                LDA #$40
                CPX #$37
                BCS A70
                LDA #$C0
A70             STA TEMPR
                JSR TERRB
                BNE A74
                LDA TRNCOD
                AND #$C0
                CMP TEMPR
                BEQ A71
                LDA CorpsX,X
                CMP LONG
                BNE A79
                LDA CorpsY,X
                CMP LAT
                BEQ A74
A79             RTS
A71             LDA #$02
                STA ZOC
                RTS
A74             LDX #$07
LOOPQ           LDY JSTP+16,X
                LDA LONG
                CLC
                ADC XINC,Y
                STA LONG
                LDA LAT
                CLC
                ADC YINC,Y
                STA LAT
                JSR TERRB
                BNE A75
                LDA TRNCOD
                AND #$C0
                CMP TEMPR
                BNE A75
                TXA
                AND #$01
                CLC
                ADC #$01
                ADC ZOC
                STA ZOC
A75             DEX
                BPL LOOPQ
                DEC LAT
                DEC LONG
                LDX ARMY
                RTS
;
;
DEAD            LDA #$00
                STA MusterStrength,X
                STA CombatStrength,X
                STA HowManyOrders,X
                LDA #$FF
                STA EXEC,X
                STA ArrivalTurn,X
                STX CORPS
                LDA CorpsX,X
                STA CHUNKX
                LDA CorpsY,X
                STA CHUNKY
                JSR SWITCH
                RTS
;
;Subroutine BRKCHK evaluates whether a unit under attack breaks
;
BRKCHK          CPX #$37
                BCS WEAKLG
                LDA CorpType,X
                AND #$F0
                BNE WEAKLG
                LDA MusterStrength,X
                LSR A
                JMP Y40
WEAKLG          LDA MusterStrength,X
                LSR A
                LSR A
                LSR A
                STA TEMPR
                LDA MusterStrength,X
                SEC
                SBC TEMPR
Y40             CMP CombatStrength,X
                BCC A30
                LDA #$FF
                STA EXEC,X
                LDA #$00
                STA HowManyOrders,X
A30             RTS

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ; added for binary compatibility

                .word $A90A

                .fill 384,$00

;
;Subroutine BRKCHK2 evaluates whether a unit under attack breaks
;
BRKCHK2         CPX #$47
                BCS WEAKLG2
                LDA CorpType,X
                AND #$F0
                BNE WEAKLG2
                LDA MusterStrength,X
                LSR A
                JMP Y40_2
WEAKLG2         LDA MusterStrength,X
                LSR A
                LSR A
                LSR A
                STA TEMPR
                LDA MusterStrength,X
                SEC
                SBC TEMPR
Y40_2           CMP CombatStrength,X
                bcs A30_2
                LDA #$FF
                STA EXEC,X
                LDA #$00
                STA HowManyOrders,X
A30_2           RTS

                .fill 41,$00

;
;Subroutine BRKCHK3 evaluates whether a unit under attack breaks
;
BRKCHK4         CPX #$47
                BCS WEAKLG3
                LDA CorpType,X
                AND #$F0
                BNE WEAKLG3
                LDA MusterStrength,X
                LSR A
                JMP Y40_3
WEAKLG3         LDA MusterStrength,X
                LSR A
                LSR A
                LSR A
                STA TEMPR
                LDA MusterStrength,X
                SEC
                SBC TEMPR
Y40_3           CMP CombatStrength,X
                RTS

                .fill 3,$00

            .END
