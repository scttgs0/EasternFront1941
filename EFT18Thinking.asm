;==================================================================
;==================================================================
;EFT VERSION 1.8T (THINKING) 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

                .cpu "65816"

                .include "equates_system_atari8.asm"
                .include "equates_directpage.asm"
                .include "equates_page6.asm"

;   declarations of routines in other modules
DEFNC           = $79B4
ROTARR          = $7A78
OBJX            = $7A91
JSTP            = $799C

;--------------------------------------
;--------------------------------------
                * = $7BD9
;--------------------------------------
NDX             .fill 24
YINC            .byte ?
XINC            .fill 4
OFFNC           .fill 10
OBJY            = $5398
IFR             = $698
TERR            = $7240
Y00             = $72DE

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
;Russian artificial intelligence routine
;

;--------------------------------------
;--------------------------------------
                * = $4700
;--------------------------------------

;   initialization loop
                LDX #$01
                STA TEMPR
                STA TOTRS
                STA TOTGS
                LDY #$9E
LOOP80          LDA ArrivalTurn,Y
                CMP TURN
                BCS Z50
                LDA TEMPR
                CLC
                ADC CombatStrength,Y
                STA TEMPR
                BCC Z50
                INC TOTGS,X
Z50             DEY
                CPY #$37
                BCS LOOP80
                LDX #$00
                CPY #$00
                BNE LOOP80

;   shift values 4 places right
                LDA TOTRS
                STA TEMPR
                LDA TOTGS
                LDX #$04
LOOP81          ASL A
                BCC Z51
                ROR A
LOOP82          LSR TEMPR
                DEX
                BNE LOOP82
                BEQ Z52
Z51             DEX
                BNE LOOP81

;   calculate overall force ratio
Z52             LDY #$FF
                LDX TEMPR
                BEQ Z53
                SEC
LOOP83          INY
                SBC TEMPR
                BCS LOOP83
Z53             STY OFR

;   calculate individual force ratios
                LDX #$9E
LOOP50          STX ARMY
                LDA ArrivalTurn,X
                CMP TURN
                BCS Y44
                JSR CALIFR
                LDA CorpsX,X
                STA OBJX-55,X
                LDA CorpsY,X
                STA OBJY-55,X
Y44             DEX
                CPX #$37
                BCS LOOP50

;   here begins the main loop
MLOOP           LDX #$9E                ; outer loop for entire Russian army
LOOP51          STX ARMY                ; inner loop for individual armies
                LDA ArrivalTurn,X
                CMP TURN
                BCC Z26
Z54             JMP TOGSCN
Z26             LDA CorpType,X
                CMP #$04
                BEQ Z54
                LDA OFR                 ; is army near the front?
                LSR A
                CMP IFR-55,X
                BNE Y51                 ; yes
                STA BVAL                ; no, treat as reinforcement

;   find nearby beleaguered army
                LDY #$9E
LOOP52          LDA ArrivalTurn,Y
                CMP TURN
                BCS Y54
                LDA CorpsX,Y
                SEC
                SBC CorpsX,X
                JSR INVERT
                STA TEMPR
                LDA CorpsY,Y
                SEC
                SBC CorpsY,X
                JSR INVERT
                CLC
                ADC TEMPR
                LSR A
                LSR A
                LSR A
                BCS Y54
                STA TEMPR
                LDA IFR-55,Y
                SEC
                SBC TEMPR
                BCC Y54                 ; no good using nearby armies
                CMP BVAL
                BCC Y54
                STA BVAL
                STY BONE
Y54             DEY
                CPY #$37
                BCS LOOP52
                LDY BONE                ; beleagueredest army
                LDA CorpsX,Y
                STA OBJX-55,X
                LDA CorpsY,Y
                STA OBJY-55,X
                JMP TOGSCN

;   front line armies
Y51             LDA #$FF
                STA DIR                 ; a direction of $FF means 'stay put'
                STA BONE
                LDA #$00
                STA BVAL

;   ad hoc logic for surrounded people
                LDA IFRE-55,X
                CMP #$10
                BCS Z55
                LDA MusterStrength,X
                LSR A
                CMP CombatStrength,X            ; out of supply?
                BCC DRLOOP
Z55             LDA CorpsX,X            ; head due east!
                SEC
                SBC #$05
                BCS Z96
                LDA #$00
Z96             STA OBJX-55,X
                JMP TOGSCN
DRLOOP          LDA OBJX-55,X
                LDY DIR
                BMI Y55
                CLC
                ADC XINC,Y
Y55             STA TARGX
                LDA OBJY-55,X
                LDY DIR
                BMI Y56
                CLC
                ADC YINC,Y
Y56             STA TARGY
                LDA #$00
                STA SQVAL
                LDA DIR
                BMI Y57
                STA WhatOrders,X
                JSR Y00
                LDY ARMY
                LDA EXEC,Y              ; is square accessible?
                BPL Y57                 ; yes
                JMP EVALSQ              ; no, skip this square

;   fill in the direct line array
Y57             LDA #$00
                STA LINCOD
                LDA TARGX
                STA SQX
                LDA TARGY
                STA SQY
                LDY #$17
LOOP56          STY JCNT
                LDA JSTP,Y
                TAY
                LDA SQX
                CLC
                ADC XINC,Y
                STA SQX
                LDA SQY
                CLC
                ADC YINC,Y
                STA SQY

                LDX #$9E
LOOP55          LDA ArrivalTurn,X
                CMP TURN
                BEQ Z25
                BCS Y58
Z25             LDA OBJX-55,X
                CMP SQX
                BNE Y58
                LDA OBJY-55,X
                CMP SQY
                BNE Y58
                CPX ARMY
                BEQ Y31
                LDA MusterStrength,X
                BNE Y59
Y58             DEX
                CPX #$37
                BCS LOOP55
Y31             LDA #$00
Y59             LDY JCNT
                LDX NDX,Y
                STA LINARR,X
                DEY
                BPL LOOP56

                LDX ARMY
                LDA MusterStrength,X
                STA LINARR+12
                LDA #$00
                STA ACCLO
                STA ACCHI
                STA SECDIR

;   build LV array
Y88             LDX #$00
                STX POTATO
Y92             LDY #$00
Y90             LDA LINARR,X
                BNE Y89
                INX
                INY
                CPY #$05
                BNE Y90
Y89             LDX POTATO
                TYA
                STA LV,X
                INX
                STX POTATO
                CPX #$01
                BNE Y91
                LDX #$05
                BNE Y92
Y91             CPX #$02
                BNE Y93
                LDX #$0A
                BNE Y92

Y93             CPX #$03
                BNE Z40
                LDX #$0F
                BNE Y92
Z40             CPX #$04
                BNE Z41
                LDX #$14
                BNE Y92

Z41             LDA #$00
                LDY #$04
LOOP76          LDX LV,Y
                CPX #$05
                BEQ Z42
                CLC
                ADC #$28
Z42             DEY
                BPL LOOP76

;   add bonus if central column is otherwise empty
                LDY LINARR+10
                BNE Y95
                LDY LINARR+11
                BNE Y95
                LDY LINARR+13
                BNE Y95
                LDY LINARR+14
                BNE Y95
                CLC
                ADC #$30
Y95             STA LPTS

;   evaluate blocking penalty
                LDX #$00
LOOP72          LDA LV,X
                CMP #$04
                BCS Y96
                STA TEMPR
                STX TEMPZ
                TXA
                ASL A
                ASL A
                ADC TEMPZ
                ADC TEMPR
                TAY
                INY
                LDA LINARR,Y
                BEQ Y96
                LDA LPTS
                SEC
                SBC #$20
                BCS A91
                LDA #$00
A91             STA LPTS
Y96             INX
                CPX #$05
                BNE LOOP72

;   evaluate vulnerability to penetrations
                LDY #$00
LOOP54          STY OCOLUM
                LDX #$00
LOOP73          STX COLUM
                CPX OCOLUM
                BEQ NXCLM
                LDA LV,X
                SEC
                SBC LV,Y
                BEQ NXCLM
                BMI NXCLM
                TAX
                LDA #$01
LOOP74          ASL A
                DEX
                BNE LOOP74
                STA TEMPR
                LDA LPTS
                SEC
                SBC TEMPR
                BCS Y32
                LDA #$00
Y32             STA LPTS
NXCLM           LDX COLUM
                INX
                CPX #$05
                BNE LOOP73
                INY
                CPY #$05
                BNE LOOP54

;   get overall line value weighted by danger vector
                LDX ARMY
                LDY SECDIR
                BNE Z18
                LDA IFRN-55,X
                JMP Z20
Z18             CPY #$01
                BNE Z19
                LDA IFRE-55,X
                JMP Z20
Z19             CPY #$02
                BNE Z17
                LDA IFRS-55,X
                JMP Z20
Z17             LDA IFRW-55,X
Z20             STA TEMPR
                LDX LPTS
                BEQ Z49
                LDA ACCLO
                CLC
LOOP75          ADC TEMPR
                BCC Y34
                INC ACCHI
                CLC
                BNE Y34
                LDA #$FF
                STA ACCHI
Y34             DEX
                BNE LOOP75

;   next secondary direction
Z49             INY
                CPY #$04
                BEQ Y35
                STY SECDIR

;   rotate array
                LDX #$18
LOOP70          LDA LINARR,X
                STA BAKARR,X
                DEX
                BPL LOOP70
                LDX #$18
LOOP71          LDY ROTARR,X
                LDA BAKARR,X
                STA LINARR,Y
                DEX
                BPL LOOP71
                JMP Y88


Y35             LDA ACCHI
                STA SQVAL

;   get range to closest German into NBVAL
Y65             LDY #$36
                LDA #$FF
                STA NBVAL
LOOP59          LDA ArrivalTurn,Y
                CMP TURN
                BEQ Z45
                BCS Y68
Z45             LDA CorpsX,Y
                SEC
                SBC TARGX
                JSR INVERT
                STA TEMPR
                LDA CorpsY,Y
                SEC
                SBC TARGY
                JSR INVERT
                CLC
                ADC TEMPR
                CMP NBVAL
                BCS Y68
                STA NBVAL
Y68             DEY
                BPL LOOP59

;   determine whether to use offensive or defensive strategy
                LDX ARMY
                LDA IFR-55,X
                STA TEMPR
                LDA #$0F
                SEC
                SBC TEMPR
                BCC A40
                ASL A                   ;OK, let's fool the routine
                STA TEMPR
                LDA #$09
                SEC
                SBC NBVAL               ; I know that NBVAL<9 for all front line units
                STA NBVAL

;   add NBVAL*IFR to SQVAL with defensive bonus
A40             LDY NBVAL
                BNE Z24                 ; this square occupied by a German?
                STY SQVAL               ; yes, do not enter!!!
                JMP EVALSQ
Z24             LDY TRNTYP
                LDA DEFNC,Y
                CLC
                ADC NBVAL
                TAY
                LDA #$00
                CLC
LOOP60          ADC TEMPR
                BCC Y69
Z22             LDA #$FF
                BMI Y71
Y69             DEY
                BNE LOOP60

Y71             CLC
                ADC SQVAL
                BCC X00
                LDA #$FF
X00             STA SQVAL

;   extract penalty if somebody else has dibs on this square
                LDY #$9E
LOOP58          LDA OBJX-55,Y
                CMP TARGX
                BNE Y63
                LDA OBJY-55,Y
                CMP TARGY
                BNE Y63
                CPY ARMY
                BEQ Y63
                LDA ArrivalTurn,Y
                CMP TURN
                BEQ Z44
                BCS Y63
Z44             LDA SQVAL
                SBC #$20
                STA SQVAL
                JMP EVALSQ
Y63             DEY
                CPY #$37
                BCS LOOP58

;   extract distance penalty
Y60             LDA CorpsX,X
                SEC
                SBC TARGX
                JSR INVERT
                STA TEMPR
                LDA CorpsY,X
                SEC
                SBC TARGY
                JSR INVERT
                CLC
                ADC TEMPR
                CMP #$07
                BCC Z48
                LDA #$00
                STA SQVAL               ; this square is too far away
                BEQ EVALSQ

Z48             TAX
                LDA #$01
LOOP77          ASL A
                DEX
                BPL LOOP77
                STA TEMPR
                LDA SQVAL
                SEC
                SBC TEMPR
                STA SQVAL
                BCS EVALSQ
                LDA #$00
                STA SQVAL

;   evaluate this square
EVALSQ          LDY DIR
                LDX ARMY
                LDA SQVAL
                CMP BVAL
                BCC Y72
                STA BVAL
                STY BONE
Y72             INY
                CPY #$04
                BEQ Y73
                STY DIR
                JMP DRLOOP

Y73             LDA OBJX-55,X
                LDY BONE
                BMI Y74
                CLC
                ADC XINC,Y
Y74             STA OBJX-55,X
                LDA OBJY-55,X
                LDY BONE
                BMI Y75
                CLC
                ADC YINC,Y
Y75             STA OBJY-55,X


TOGSCN          LDA TRIG0
                BEQ A30                 ; ignore game console if red button is down
                LDA #$08
                STA CONSOL
                LDA CONSOL
                AND #$01
                BEQ WRAPUP
A30             DEX
                CPX #$37
                BCC Y76
                JMP LOOP51
Y76             JMP MLOOP

WRAPUP          LDX #$9E
LOOP62          STX ARMY
                LDA ArrivalTurn,X
                CMP TURN
                BCC Y78
                JMP Y77
Y78             LDA OBJX-55,X
                LDY #$03
                SEC
                SBC CorpsX,X
                BPL Y79
                LDY #$01
                JSR INVERT+2
Y79             STY HDIR
                STA HRNGE
                LDY #$00
                LDA OBJY-55,X
                SEC
                SBC CorpsY,X
                BPL Y80
                LDY #$02
                JSR INVERT+2
Y80             STY VDIR
                STA VRNGE
                CMP HRNGE
                BCC Y81
                STA LRNGE
                LDA HRNGE
                STA SRNGE
                LDA HDIR
                STA SDIR
                STY LDIR
                JMP Y82
Y81             STA SRNGE
                STY SDIR
                LDA HRNGE
                STA LRNGE
                LDY HDIR
                STY LDIR
Y82             LDA #$00
                STA RCNT
                STA RORD1
                STA RORD2
                LDA LRNGE
                CLC
                ADC SRNGE
                STA RANGE
                BEQ Y86
                LDA LRNGE
                LSR A
                STA CHRIS

LOOP61          LDA CHRIS
                CLC
                ADC SRNGE
                STA CHRIS
                SEC
                SBC RANGE
                BCS OVRFLO
                LDA LDIR
                BCC STIP
OVRFLO          STA CHRIS
                LDA SDIR
STIP            STA DIR
                LDA RCNT
                AND #$03
                TAY
                STA TEMPR
                LDA RCNT
                LSR A
                LSR A
                TAX
                LDA DIR
Y85             DEY
                BMI Y84
                ASL A
                ASL A
                JMP Y85

Y84             LDY TEMPR
                EOR RORD1,X
                AND MASKO,Y
                EOR RORD1,X
                STA RORD1,X
                LDX RCNT
                INX
                STX RCNT
                CPX #$08
                BCS Y86
                CPX RANGE
                BCC LOOP61
Y86             LDX ARMY
                LDA RORD1
                STA WhatOrders,X
                LDA RORD2
                STA WHORDH,X
                LDA RCNT
                STA HowManyOrders,X

Y77             DEX
                CPX #$37
                BCC Y87
                JMP LOOP62
Y87             RTS

;
;Subroutine CALIFR determines individual force ratios
;in all four directions
;
CALIFR          LDY #$00                ; initialize vectors
                STY IFR0
                STY IFR1
                STY IFR2
                STY IFR3
                STY IFRHI
                INY
                STY RFR
                LDA CorpsX,X
                STA XLOC
                LDA CorpsY,X
                STA YLOC
                LDY #$9E
LOOP53          LDA ArrivalTurn,Y
                CMP TURN
                BCS Z07
                LDA CorpsY,Y
                SEC
                SBC YLOC
                STA TEMPY               ; save signed vector
                JSR INVERT
                STA TEMPR
                LDA CorpsX,Y
                SEC
                SBC XLOC
                STA TEMPX
                JSR INVERT
                CLC
                ADC TEMPR
Z21             CMP #$09                ;no point in checking if he's too far
Z07             BCS Y48
                LSR A
                STA TEMPR               ; this is half of range to unit

;   select which IFR gets this German
                LDA TEMPX
                BPL Z00
                LDA TEMPY
                BPL Z01
                LDX #$02
                CMP TEMPX
                BCS Z02
                LDX #$01
                BCC Z02
Z00             LDA TEMPY
                BPL Z03
                JSR INVERT+2
                LDX #$02
                CMP TEMPX
                BCS Z02
                LDX #$03
                BCC Z02
Z03             LDX #$00
                CMP TEMPX
                BCS Z02
                LDX #$03
                BCC Z02
Z01             LDA TEMPX
                JSR INVERT+2
                LDX #$01
                CMP TEMPY
                BCS Z02
                LDX #$00
Z02             LDA CombatStrength,Y
                LSR A
                LSR A
                LSR A
                LSR A
Z11             CPY #$37
                BCC Z12
                CLC
                ADC RFR
                BCC Z13
                LDA #$FF
Z13             STA RFR
                JMP Y48
Z12             CLC
                ADC IFR0,X
                BCC Z05
                LDA #$FF
Z05             STA IFR0,X
Y48             DEY
                BEQ Z06
                JMP LOOP53

Z06             LDX #$03
                LDA #$00
Y37             CLC
                ADC IFR0,X
                BCC Y36
                LDA #$FF
Y36             DEX
                BPL Y37


                ASL A
                ROL IFRHI
                ASL A
                ROL IFRHI
                ASL A
                ROL IFRHI
                ASL A
                ROL IFRHI
                LDX #$00
                SEC
Z16             SBC RFR
                BCS Z14
                DEC IFRHI
                SEC
                BMI Z15
Z14             INX
                JMP Z16
Z15             TXA
                LDX ARMY
                CLC
                ADC OFR                 ; remember strategic situation
                ROR A                   ; average strategic with tactical
                STA IFR-55,X

;   keep a record of danger vector
                LDA IFR0
                STA IFRN-55,X
                LDA IFR1
                STA IFRE-55,X
                LDA IFR2
                STA IFRS-55,X
                LDA IFR3
                STA IFRW-55,X
                RTS

INVERT          BPL Z46
                EOR #$FF
                CLC
                ADC #$01
Z46             RTS

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;   added for binary compatibility

; IFRN            .fill 104,$00
; IFRE            .fill 104,$00
; IFRS            .fill 104,$00
; IFRW            .fill 104,$00

IFRN            .byte $01,$60,$4e,$60,$10,$05,$49,$ff
                .byte $18,$69,$01,$60,$06,$9d,$6e,$4d
                .byte $ad,$7e,$06,$9d,$b9,$00,$ad,$7f
                .byte $06,$9d,$11,$01,$60,$10,$05,$49
                .byte $ff,$18,$69,$01,$60,$7e,$06,$9d
                .byte $da,$4d,$ad,$7f,$06,$9d,$32,$4e
                .byte $60,$10,$05,$49,$ff,$18,$69,$01
                .byte $60,$69,$01,$60,$9d,$b3,$5e,$ad
                .byte $4d,$06,$9d,$75,$5d,$ca,$e0,$47
                .byte $90,$03,$4c,$8d,$4c,$60,$a9,$00
                .byte $8d,$82,$06,$8d,$83,$06,$8d,$84
                .byte $06,$8d,$85,$06,$8d,$92,$06,$8d
                .byte $93,$06,$bd,$00,$54,$8d,$86,$06

IFRE            .byte $bd,$9f,$54,$8d,$87,$06,$a0,$9e
                .byte $b9,$1b,$57,$cd,$23,$06,$90,$03
                .byte $4c,$4b,$4e,$b9,$9f,$54,$38,$ed
                .byte $87,$06,$8d,$89,$06,$10,$05,$49
                .byte $ff,$18,$69,$01,$85,$c5,$b9,$00
                .byte $54,$38,$ed,$86,$06,$8d,$88,$06
                .byte $10,$05,$49,$ff,$18,$69,$01,$18
                .byte $65,$c5,$c9,$09,$b0,$6d,$4a,$85
                .byte $c5,$ad,$88,$06,$10,$10,$ad,$89
                .byte $06,$10,$2b,$a2,$02,$cd,$88,$06
                .byte $b0,$35,$a2,$01,$90,$31,$ad,$89
                .byte $06,$10,$10,$49,$ff,$18,$69,$01
                .byte $a2,$02,$cd,$88,$06,$b0,$20,$a2

IFRS            .byte $03,$90,$1c,$a2,$00,$cd,$88,$06
                .byte $b0,$15,$a2,$03,$90,$11,$ad,$88
                .byte $06,$49,$ff,$18,$69,$01,$a2,$01
                .byte $cd,$89,$06,$b0,$02,$a2,$00,$b9
                .byte $dd,$55,$4a,$4a,$4a,$4a,$c0,$47
                .byte $90,$0e,$18,$6d,$92,$06,$90,$02
                .byte $a9,$ff,$8d,$92,$06,$4c,$4b,$4e
                .byte $18,$7d,$82,$06,$90,$02,$a9,$ff
                .byte $9d,$82,$06,$88,$f0,$03,$4c,$a8
                .byte $4d,$a2,$03,$a9,$00,$18,$7d,$82
                .byte $06,$90,$02,$a9,$ff,$ca,$10,$f5
                .byte $0a,$2e,$93,$06,$0a,$2e,$93,$06
                .byte $0a,$2e,$93,$06,$0a,$2e,$93,$06

IFRW            .byte $a2,$00,$38,$ed,$92,$06,$b0,$06
                .byte $ce,$93,$06,$38,$30,$04,$e8,$4c
                .byte $73,$4e,$8a,$a6,$c2,$18,$6d,$99
                .byte $06,$6a,$9d,$e0,$3d,$ad,$82,$06
                .byte $9d,$5f,$4e,$ad,$83,$06,$9d,$b7
                .byte $4e,$ad,$84,$06,$9d,$0f,$4f,$ad
                .byte $85,$06,$9d,$67,$4f,$60,$a6,$c2
                .byte $18,$6d,$99,$06,$6a,$9d,$e0,$3d
                .byte $ad,$82,$06,$9d,$82,$4e,$ad,$83
                .byte $06,$9d,$da,$4e,$ad,$84,$06,$9d
                .byte $32,$4f,$ad,$85,$06,$9d,$8a,$4f
                .byte $60,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

            .END
