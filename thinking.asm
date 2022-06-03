;==================================================================
;==================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

;
;Russian artificial intelligence routine
;

;--------------------------------------
;--------------------------------------
                * = $02_4700
;--------------------------------------

;   initialization loop
INIT            ldx #$01
                sta TEMPR
                sta TOTRS
                sta TOTGS
                ldy #$9E
LOOP80          lda ArrivalTurn,Y
                cmp TURN
                bcs Z50

                lda TEMPR
                clc
                adc CombatStrength,Y
                sta TEMPR
                bcc Z50

                inc TOTGS,X
Z50             dey
                cpy #$37
                bcs LOOP80

                ldx #$00
                cpy #$00
                bne LOOP80

;   shift values 4 places right
                lda TOTRS
                sta TEMPR
                lda TOTGS
                ldx #$04
LOOP81          asl A
                bcc Z51

                ror A
LOOP82          lsr TEMPR
                dex
                bne LOOP82
                beq Z52

Z51             dex
                bne LOOP81

;   calculate overall force ratio
Z52             ldy #$FF
                ldx TEMPR
                beq Z53

                sec
LOOP83          iny
                sbc TEMPR
                bcs LOOP83

Z53             sty OFR

;   calculate individual force ratios
                ldx #$9E
LOOP50          stx ARMY
                lda ArrivalTurn,X
                cmp TURN
                bcs Y44

                jsr CALIFR

                lda CorpsX,X
                sta OBJX-55,X
                lda CorpsY,X
                sta OBJY-55,X
Y44             dex
                cpx #$37
                bcs LOOP50

;   here begins the main loop
MLOOP           ldx #$9E                ; outer loop for entire Russian army
LOOP51          stx ARMY                ; inner loop for individual armies
                lda ArrivalTurn,X
                cmp TURN
                bcc Z26

Z54             jmp TOGSCN

Z26             lda CorpType,X
                cmp #$04
                beq Z54

                lda OFR                 ; is army near the front?
                lsr A
                cmp IFR-55,X
                bne Y51                 ; yes

                sta BVAL                ; no, treat as reinforcement

;   find nearby beleaguered army
                ldy #$9E
LOOP52          lda ArrivalTurn,Y
                cmp TURN
                bcs Y54

                lda CorpsX,Y
                sec
                sbc CorpsX,X
                jsr INVERT

                sta TEMPR
                lda CorpsY,Y
                sec
                sbc CorpsY,X
                jsr INVERT

                clc
                adc TEMPR
                lsr A
                lsr A
                lsr A
                bcs Y54

                sta TEMPR
                .setbank $00
                lda IFR-55,Y
                .setbank $02
                sec
                sbc TEMPR
                bcc Y54                 ; no good using nearby armies

                cmp BVAL
                bcc Y54

                sta BVAL
                sty BONE
Y54             dey
                cpy #$37
                bcs LOOP52

                ldy BONE                ; beleagueredest army
                lda CorpsX,Y
                sta OBJX-55,X
                lda CorpsY,Y
                sta OBJY-55,X
                jmp TOGSCN

;   front line armies
Y51             lda #$FF
                sta DIR                 ; a direction of $FF means 'stay put'
                sta BONE
                lda #$00
                sta BVAL

;   ad-hoc logic for surrounded people
                lda IFRE-55,X
                cmp #$10
                bcs Z55

                lda MusterStrength,X
                lsr A
                cmp CombatStrength,X    ; out of supply?
                bcc DRLOOP

Z55             lda CorpsX,X            ; head due east!
                sec
                sbc #$05
                bcs Z96

                lda #$00
Z96             sta OBJX-55,X
                jmp TOGSCN

DRLOOP          lda OBJX-55,X
                ldy DIR
                bmi Y55

                clc
                adc XINC,Y
Y55             sta TARGX
                lda OBJY-55,X
                ldy DIR
                bmi Y56

                clc
                adc YINC,Y
Y56             sta TARGY
                lda #$00
                sta SQVAL
                lda DIR
                bmi Y57

                sta WhatOrders,X
                jsr Y00

                ldy ARMY
                lda EXEC,Y              ; is square accessible?
                bpl Y57                 ; yes

                jmp EVALSQ              ; no, skip this square

;   fill in the direct line array
Y57             lda #$00
                sta LINCOD
                lda TARGX
                sta SQX
                lda TARGY
                sta SQY
                ldy #$17
LOOP56          sty JCNT
                lda JSTP,Y
                tay
                lda SQX
                clc
                adc XINC,Y
                sta SQX
                lda SQY
                clc
                adc YINC,Y
                sta SQY

                ldx #$9E
LOOP55          lda ArrivalTurn,X
                cmp TURN
                beq Z25
                bcs Y58

Z25             lda OBJX-55,X
                cmp SQX
                bne Y58

                lda OBJY-55,X
                cmp SQY
                bne Y58

                cpx ARMY
                beq Y31

                lda MusterStrength,X
                bne Y59

Y58             dex
                cpx #$37
                bcs LOOP55

Y31             lda #$00
Y59             ldy JCNT
                ldx NDX,Y
                sta LINARR,X
                dey
                bpl LOOP56

                ldx ARMY
                lda MusterStrength,X
                sta LINARR+12
                lda #$00
                sta ACCLO
                sta ACCHI
                sta SECDIR

;   build LV array
Y88             ldx #$00
                stx POTATO
Y92             ldy #$00
Y90             lda LINARR,X
                bne Y89

                inx
                iny
                cpy #$05
                bne Y90

Y89             ldx POTATO
                tya
                sta LV,X
                inx
                stx POTATO
                cpx #$01
                bne Y91

                ldx #$05
                bne Y92

Y91             cpx #$02
                bne Y93

                ldx #$0A
                bne Y92


Y93             cpx #$03
                bne Z40

                ldx #$0F
                bne Y92

Z40             cpx #$04
                bne Z41

                ldx #$14
                bne Y92


Z41             lda #$00
                ldy #$04
LOOP76          ldx LV,Y
                cpx #$05
                beq Z42

                clc
                adc #$28
Z42             dey
                bpl LOOP76

;   add bonus if central column is otherwise empty
                ldy LINARR+10
                bne Y95

                ldy LINARR+11
                bne Y95

                ldy LINARR+13
                bne Y95

                ldy LINARR+14
                bne Y95

                clc
                adc #$30
Y95             sta LPTS

;   evaluate blocking penalty
                ldx #$00
LOOP72          lda LV,X
                cmp #$04
                bcs Y96

                sta TEMPR
                stx TEMPZ
                txa
                asl A
                asl A
                adc TEMPZ
                adc TEMPR
                tay
                iny
                .setbank $00
                lda LINARR,Y
                .setbank $02
                beq Y96

                lda LPTS
                sec
                sbc #$20
                bcs A91

                lda #$00
A91             sta LPTS
Y96             inx
                cpx #$05
                bne LOOP72

;   evaluate vulnerability to penetrations
                ldy #$00
LOOP54          sty OCOLUM
                ldx #$00
LOOP73          stx COLUM
                cpx OCOLUM
                beq NXCLM

                .setbank $00
                lda LV,X
                sec
                sbc LV,Y
                .setbank $02
                beq NXCLM
                bmi NXCLM

                tax
                lda #$01
LOOP74          asl A
                dex
                bne LOOP74

                sta TEMPR
                lda LPTS
                sec
                sbc TEMPR
                bcs Y32

                lda #$00
Y32             sta LPTS
NXCLM           ldx COLUM
                inx
                cpx #$05
                bne LOOP73

                iny
                cpy #$05
                bne LOOP54

;   get overall line value weighted by danger vector
                ldx ARMY
                ldy SECDIR
                bne Z18

                lda IFRN-55,X
                jmp Z20

Z18             cpy #$01
                bne Z19

                lda IFRE-55,X
                jmp Z20

Z19             cpy #$02
                bne Z17

                lda IFRS-55,X
                jmp Z20

Z17             lda IFRW-55,X
Z20             sta TEMPR
                ldx LPTS
                beq Z49

                lda ACCLO
                clc
LOOP75          adc TEMPR
                bcc Y34

                inc ACCHI
                clc
                bne Y34

                lda #$FF
                sta ACCHI
Y34             dex
                bne LOOP75

;   next secondary direction
Z49             iny
                cpy #$04
                beq Y35

                sty SECDIR

;   rotate array
                ldx #$18
LOOP70          lda LINARR,X
                sta BAKARR,X
                dex
                bpl LOOP70

                ldx #$18
LOOP71          ldy ROTARR,X
                .setbank $00
                lda BAKARR,X
                sta LINARR,Y
                .setbank $02
                dex
                bpl LOOP71

                jmp Y88

Y35             lda ACCHI
                sta SQVAL

;   get range to closest German into NBVAL
Y65             ldy #$36
                lda #$FF
                sta NBVAL
LOOP59          lda ArrivalTurn,Y
                cmp TURN
                beq Z45
                bcs Y68

Z45             lda CorpsX,Y
                sec
                sbc TARGX
                jsr INVERT

                sta TEMPR
                lda CorpsY,Y
                sec
                sbc TARGY
                jsr INVERT

                clc
                adc TEMPR
                cmp NBVAL
                bcs Y68

                sta NBVAL
Y68             dey
                bpl LOOP59

;   determine whether to use offensive or defensive strategy
                ldx ARMY
                lda IFR-55,X
                sta TEMPR
                lda #$0F
                sec
                sbc TEMPR
                bcc A40

                asl A                   ;OK, let's fool the routine
                sta TEMPR
                lda #$09
                sec
                sbc NBVAL               ; I know that NBVAL<9 for all front line units
                sta NBVAL

;   add NBVAL*IFR to SQVAL with defensive bonus
A40             ldy NBVAL
                bne Z24                 ; this square occupied by a German?

                sty SQVAL               ; yes, do not enter!!!
                jmp EVALSQ

Z24             ldy TRNTYP
                lda DEFNC,Y
                clc
                adc NBVAL
                tay
                lda #$00
                clc
LOOP60          adc TEMPR
                bcc Y69

Z22             lda #$FF
                bmi Y71

Y69             dey
                bne LOOP60

Y71             clc
                adc SQVAL
                bcc X00

                lda #$FF
X00             sta SQVAL

;   extract penalty if somebody else has dibs on this square
                ldy #$9E
LOOP58          lda OBJX-55,Y
                cmp TARGX
                bne Y63

                lda OBJY-55,Y
                cmp TARGY
                bne Y63

                cpy ARMY
                beq Y63

                lda ArrivalTurn,Y
                cmp TURN
                beq Z44
                bcs Y63

Z44             lda SQVAL
                sbc #$20
                sta SQVAL
                jmp EVALSQ

Y63             dey
                cpy #$37
                bcs LOOP58

;   extract distance penalty
Y60             lda CorpsX,X
                sec
                sbc TARGX
                jsr INVERT

                sta TEMPR
                lda CorpsY,X
                sec
                sbc TARGY
                jsr INVERT

                clc
                adc TEMPR
                cmp #$07
                bcc Z48

                lda #$00
                sta SQVAL               ; this square is too far away
                beq EVALSQ

Z48             tax
                lda #$01
LOOP77          asl A
                dex
                bpl LOOP77

                sta TEMPR
                lda SQVAL
                sec
                sbc TEMPR
                sta SQVAL
                bcs EVALSQ

                lda #$00
                sta SQVAL

;   evaluate this square
EVALSQ          ldy DIR
                ldx ARMY
                lda SQVAL
                cmp BVAL
                bcc Y72

                sta BVAL
                sty BONE
Y72             iny
                cpy #$04
                beq Y73

                sty DIR
                jmp DRLOOP

Y73             lda OBJX-55,X
                ldy BONE
                bmi Y74

                clc
                adc XINC,Y
Y74             sta OBJX-55,X
                lda OBJY-55,X
                ldy BONE
                bmi Y75

                clc
                adc YINC,Y
Y75             sta OBJY-55,X

TOGSCN          lda JOYSTICK0           ; read joystick0 button
                and #$10
                beq A30                 ; ignore game console if red button is down

                lda #$08
                sta CONSOL  ; TODO:platform     ; reset function keys
                lda CONSOL  ; TODO:platform     ; read function keys
                and #$01                ; START key
                beq WRAPUP

A30             dex
                cpx #$37
                bcc Y76

                jmp LOOP51

Y76             jmp MLOOP

WRAPUP          ldx #$9E
LOOP62          stx ARMY
                lda ArrivalTurn,X
                cmp TURN
                bcc Y78

                jmp Y77

Y78             lda OBJX-55,X
                ldy #$03
                sec
                sbc CorpsX,X
                bpl Y79

                ldy #$01
                jsr INVERT+2

Y79             sty HDIR
                sta HRNGE
                ldy #$00
                lda OBJY-55,X
                sec
                sbc CorpsY,X
                bpl Y80

                ldy #$02
                jsr INVERT+2

Y80             sty VDIR
                sta VRNGE
                cmp HRNGE
                bcc Y81

                sta LRNGE
                lda HRNGE
                sta SRNGE
                lda HDIR
                sta SDIR
                sty LDIR
                jmp Y82

Y81             sta SRNGE
                sty SDIR
                lda HRNGE
                sta LRNGE
                ldy HDIR
                sty LDIR
Y82             lda #$00
                sta RCNT
                sta RORD1
                sta RORD2
                lda LRNGE
                clc
                adc SRNGE
                sta RANGE
                beq Y86

                lda LRNGE
                lsr A
                sta CHRIS

LOOP61          lda CHRIS
                clc
                adc SRNGE
                sta CHRIS
                sec
                sbc RANGE
                bcs OVRFLO

                lda LDIR
                bcc STIP

OVRFLO          sta CHRIS
                lda SDIR
STIP            sta DIR
                lda RCNT
                and #$03
                tay
                sta TEMPR
                lda RCNT
                lsr A
                lsr A
                tax
                lda DIR
Y85             dey
                bmi Y84

                asl A
                asl A
                jmp Y85

Y84             ldy TEMPR
                eor RORD1,X
                and MASKO,Y
                eor RORD1,X
                sta RORD1,X
                ldx RCNT
                inx
                stx RCNT
                cpx #$08
                bcs Y86

                cpx RANGE
                bcc LOOP61

Y86             ldx ARMY
                lda RORD1
                sta WhatOrders,X
                lda RORD2
                sta WHORDH,X
                lda RCNT
                sta HowManyOrders,X

Y77             dex
                cpx #$37
                bcc Y87

                jmp LOOP62

Y87             rts

;
;Subroutine CALIFR determines individual force ratios
;in all four directions
;
CALIFR          ldy #$00                ; initialize vectors
                sty IFR0
                sty IFR1
                sty IFR2
                sty IFR3
                sty IFRHI
                iny
                sty RFR
                lda CorpsX,X
                sta XLOC
                lda CorpsY,X
                sta YLOC
                ldy #$9E
LOOP53          lda ArrivalTurn,Y
                cmp TURN
                bcs Z07

                lda CorpsY,Y
                sec
                sbc YLOC
                sta TEMPY               ; save signed vector
                jsr INVERT

                sta TEMPR
                lda CorpsX,Y
                sec
                sbc XLOC
                sta TEMPX
                jsr INVERT

                clc
                adc TEMPR
Z21             cmp #$09                ;no point in checking if he's too far
Z07             bcs Y48

                lsr A
                sta TEMPR               ; this is half of range to unit

;   select which IFR gets this German
                lda TEMPX
                bpl Z00

                lda TEMPY
                bpl Z01

                ldx #$02
                cmp TEMPX
                bcs Z02

                ldx #$01
                bcc Z02

Z00             lda TEMPY
                bpl Z03

                jsr INVERT+2

                ldx #$02
                cmp TEMPX
                bcs Z02

                ldx #$03
                bcc Z02

Z03             ldx #$00
                cmp TEMPX
                bcs Z02

                ldx #$03
                bcc Z02

Z01             lda TEMPX
                jsr INVERT+2

                ldx #$01
                cmp TEMPY
                bcs Z02

                ldx #$00
Z02             lda CombatStrength,Y
                lsr A
                lsr A
                lsr A
                lsr A
Z11             cpy #$37
                bcc Z12

                clc
                adc RFR
                bcc Z13

                lda #$FF
Z13             sta RFR
                jmp Y48

Z12             clc
                adc IFR0,X
                bcc Z05

                lda #$FF
Z05             sta IFR0,X
Y48             dey
                beq Z06

                jmp LOOP53

Z06             ldx #$03
                lda #$00
Y37             clc
                adc IFR0,X
                bcc Y36

                lda #$FF
Y36             dex
                bpl Y37

                asl A
                rol IFRHI
                asl A
                rol IFRHI
                asl A
                rol IFRHI
                asl A
                rol IFRHI
                ldx #$00
                sec
Z16             sbc RFR
                bcs Z14

                dec IFRHI
                sec
                bmi Z15

Z14             inx
                jmp Z16

Z15             txa
                ldx ARMY
                clc
                adc OFR                 ; remember strategic situation
                ror A                   ; average strategic with tactical
                sta IFR-55,X

;   keep a record of danger vector
                lda IFR0
                sta IFRN-55,X
                lda IFR1
                sta IFRE-55,X
                lda IFR2
                sta IFRS-55,X
                lda IFR3
                sta IFRW-55,X
                rts

INVERT          bpl Z46

                eor #$FF
                clc
                adc #$01
Z46             rts

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

            .end
