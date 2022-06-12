;==================================================================
;==================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

;
;Russian artificial intelligence routine
;

;======================================
; Initialization loop
;======================================
INIT            ldx #$01
                sta TEMPR
                sta TOTRS
                sta TOTGS
                ldy #$9E
_next1          lda ArrivalTurn,Y
                cmp TURN
                bcs _1

                lda TEMPR
                clc
                adc CombatStrength,Y
                sta TEMPR
                bcc _1

                inc TOTGS,X
_1              dey
                cpy #$37
                bcs _next1

                ldx #$00
                cpy #$00
                bne _next1

;   shift values 4 places right
                lda TOTRS
                sta TEMPR
                lda TOTGS
                ldx #$04
_next2          asl A
                bcc _2

                ror A
_next3          lsr TEMPR
                dex
                bne _next3
                beq _3

_2              dex
                bne _next2

;   calculate overall force ratio
_3              ldy #$FF
                ldx TEMPR
                beq _4

                sec
_next4          iny
                sbc TEMPR
                bcs _next4

_4              sty OFR

;   calculate individual force ratios
                ldx #$9E
_next5          stx ARMY
                lda ArrivalTurn,X
                cmp TURN
                bcs _5

                jsr CalculateIFR

                lda CorpsX,X
                sta OBJX-55,X
                lda CorpsY,X
                sta MoraleCheck2._OBJY-55,X
_5              dex
                cpx #$37                ; when Russian
                bcs _next5


;--------------------------------------
; Here begins the main loop
;--------------------------------------
MLOOP           ldx #$9E                ; outer loop for entire Russian army
_next1          stx ARMY                ; inner loop for individual armies
                lda ArrivalTurn,X
                cmp TURN
                bcc _1

_XIT            jmp _TOGSCN

_1              lda CorpType,X
                cmp #$04
                beq _XIT

                lda OFR                 ; is army near the front?
                lsr A
                cmp IFR-55,X
                bne _3                  ; yes

                sta BVAL                ; no, treat as reinforcement

;   find nearby beleaguered army
                ldy #$9E
_next2          lda ArrivalTurn,Y
                cmp TURN
                bcs _2

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
                bcs _2

                sta TEMPR
                .setbank $00
                lda IFR-55,Y
                .setbank $03
                sec
                sbc TEMPR
                bcc _2                  ; no good using nearby armies

                cmp BVAL
                bcc _2

                sta BVAL
                sty BONE
_2              dey
                cpy #$37
                bcs _next2

                ldy BONE                ; beleagueredest army
                lda CorpsX,Y
                sta OBJX-55,X
                lda CorpsY,Y
                sta MoraleCheck2._OBJY-55,X
                jmp _TOGSCN

;   front line armies
_3              lda #$FF
                sta DIR                 ; a direction of $FF means 'stay put'
                sta BONE
                lda #$00
                sta BVAL

;   ad-hoc logic for surrounded people
                lda IFRE-55,X
                cmp #$10
                bcs _4

                lda MusterStrength,X
                lsr A
                cmp CombatStrength,X    ; out of supply?
                bcc _next3

_4              lda CorpsX,X            ; head due east!
                sec
                sbc #$05
                bcs _5

                lda #$00
_5              sta OBJX-55,X
                jmp _TOGSCN

_next3          lda OBJX-55,X
                ldy DIR
                bmi _6

                clc
                adc XINC,Y
_6              sta TARGX
                lda MoraleCheck2._OBJY-55,X
                ldy DIR
                bmi _7

                clc
                adc YINC,Y
_7              sta TARGY
                lda #$00
                sta SQVAL
                lda DIR
                bmi _8

                sta WhatOrders,X
                jsr Y00

                ldy ARMY
                lda EXEC,Y              ; is square accessible?
                bpl _8                  ; yes

                jmp _41                 ; no, skip this square

;   fill in the direct line array
_8              lda #$00
                sta LINCOD
                lda TARGX
                sta SQX
                lda TARGY
                sta SQY
                ldy #$17
_next4          sty JCNT
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
_next5          lda ArrivalTurn,X
                cmp TURN
                beq _9
                bcs _10

_9              lda OBJX-55,X
                cmp SQX
                bne _10

                lda MoraleCheck2._OBJY-55,X
                cmp SQY
                bne _10

                cpx ARMY
                beq _11

                lda MusterStrength,X
                bne _12

_10             dex
                cpx #$37                ; when Russian
                bcs _next5

_11             lda #$00
_12             ldy JCNT
                ldx NDX,Y
                sta LINARR,X
                dey
                bpl _next4

                ldx ARMY
                lda MusterStrength,X
                sta LINARR+12
                lda #$00
                sta ACCLO
                sta ACCHI
                sta SECDIR

;   build LV array
_next6          ldx #$00
                stx POTATO
_next7          ldy #$00
_next8          lda LINARR,X
                bne _13

                inx
                iny
                cpy #$05
                bne _next8

_13             ldx POTATO
                tya
                sta LV,X
                inx
                stx POTATO
                cpx #$01
                bne _14

                ldx #$05
                bne _next7

_14             cpx #$02
                bne _15

                ldx #$0A
                bne _next7

_15             cpx #$03
                bne _16

                ldx #$0F
                bne _next7

_16             cpx #$04
                bne _17

                ldx #$14
                bne _next7

_17             lda #$00
                ldy #$04
_next9          ldx LV,Y
                cpx #$05
                beq _18

                clc
                adc #$28
_18             dey
                bpl _next9

;   add bonus if central column is otherwise empty
                ldy LINARR+10
                bne _19

                ldy LINARR+11
                bne _19

                ldy LINARR+13
                bne _19

                ldy LINARR+14
                bne _19

                clc
                adc #$30
_19             sta LPTS

;   evaluate blocking penalty
                ldx #$00
_next10         lda LV,X
                cmp #$04
                bcs _21

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
                .setbank $03
                beq _21

                lda LPTS
                ;sec
                ;sbc #$20   ?? is this screen code???
                bcs _20

                lda #$00
_20             sta LPTS
_21             inx
                cpx #$05
                bne _next10

;   evaluate vulnerability to penetrations
                ldy #$00
_next11         sty OCOLUM
                ldx #$00
_next12         stx COLUM
                cpx OCOLUM
                beq _23

                .setbank $00
                lda LV,X
                sec
                sbc LV,Y
                .setbank $03
                beq _23
                bmi _23

                tax
                lda #$01
_next13         asl A
                dex
                bne _next13

                sta TEMPR
                lda LPTS
                sec
                sbc TEMPR
                bcs _22

                lda #$00
_22             sta LPTS
_23             ldx COLUM
                inx
                cpx #$05
                bne _next12

                iny
                cpy #$05
                bne _next11

;   get overall line value weighted by danger vector
                ldx ARMY
                ldy SECDIR
                bne _24

                lda IFRN-55,X
                jmp _27

_24             cpy #$01
                bne _25

                lda IFRE-55,X
                jmp _27

_25             cpy #$02
                bne _26

                lda IFRS-55,X
                jmp _27

_26             lda IFRW-55,X
_27             sta TEMPR
                ldx LPTS
                beq _29

                lda ACCLO
                clc
_next14         adc TEMPR
                bcc _28

                inc ACCHI
                clc
                bne _28

                lda #$FF
                sta ACCHI
_28             dex
                bne _next14

;   next secondary direction
_29             iny
                cpy #$04
                beq _30

                sty SECDIR

;   rotate array
                ldx #$18
_next15         lda LINARR,X
                sta BAKARR,X
                dex
                bpl _next15

                ldx #$18
_next16         ldy ROTARR,X
                .setbank $00
                lda BAKARR,X
                sta LINARR,Y
                .setbank $03
                dex
                bpl _next16

                jmp _next6

_30             lda ACCHI
                sta SQVAL

;   get range to closest German into NBVAL
                ldy #$36
                lda #$FF
                sta NBVAL
_next17         lda ArrivalTurn,Y
                cmp TURN
                beq _31
                bcs _32

_31             lda CorpsX,Y
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
                bcs _32

                sta NBVAL
_32             dey
                bpl _next17

;   determine whether to use offensive or defensive strategy
                ldx ARMY
                lda IFR-55,X
                sta TEMPR
                lda #$0F
                sec
                sbc TEMPR
                bcc _33

                asl A                   ; OK, let's fool the routine
                sta TEMPR
                lda #$09
                sec
                sbc NBVAL               ; I know that NBVAL<9 for all front line units
                sta NBVAL

;   add NBVAL*IFR to SQVAL with defensive bonus
_33             ldy NBVAL
                bne _34                 ; this square occupied by a German?

                sty SQVAL               ; yes, do not enter!!!
                jmp _41

_34             ldy TRNTYP
                lda DEFNC,Y
                clc
                adc NBVAL
                tay
                lda #$00
                clc
_next18         adc TEMPR
                bcc _35

                lda #$FF
                bmi _36

_35             dey
                bne _next18

_36             clc
                adc SQVAL
                bcc _37

                lda #$FF
_37             sta SQVAL

;   extract penalty if somebody else has dibs on this square
                ldy #$9E
_next19         lda OBJX-55,Y
                cmp TARGX
                bne _39

                .setbank $02
                lda MoraleCheck2._OBJY-55,Y
                .setbank $03
                cmp TARGY
                bne _39

                cpy ARMY
                beq _39

                lda ArrivalTurn,Y
                cmp TURN
                beq _38
                bcs _39

_38             lda SQVAL
                sbc #$20
                sta SQVAL
                jmp _41

_39             dey
                cpy #$37
                bcs _next19

;   extract distance penalty
                lda CorpsX,X
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
                bcc _40

                lda #$00
                sta SQVAL               ; this square is too far away
                beq _41

_40             tax
                lda #$01
_next20         asl A
                dex
                bpl _next20

                sta TEMPR
                lda SQVAL
                sec
                sbc TEMPR
                sta SQVAL
                bcs _41

                lda #$00
                sta SQVAL

;   evaluate this square
_41             ldy DIR
                ldx ARMY
                lda SQVAL
                cmp BVAL
                bcc _42

                sta BVAL
                sty BONE
_42             iny
                cpy #$04
                beq _43

                sty DIR
                jmp _next3

_43             lda OBJX-55,X
                ldy BONE
                bmi _44

                clc
                adc XINC,Y
_44             sta OBJX-55,X
                lda MoraleCheck2._OBJY-55,X
                ldy BONE
                bmi _45

                clc
                adc YINC,Y
_45             sta MoraleCheck2._OBJY-55,X

_TOGSCN         ;lda JOYSTICK0           ; read joystick0 button
                lda #$1F    ; HACK:
                and #$10
                beq _46                 ; ignore game console if red button is down

                lda #$08
                sta CONSOL              ; TODO:platform     ; reset function keys
                lda CONSOL              ; TODO:platform     ; read function keys
                and #$01                ; START key
                beq _WRAPUP

_46             dex
                cpx #$37                ; when Russian
                bcc _47

                jmp _next1

_47             jmp MLOOP

_WRAPUP         ldx #$9E
_next21         stx ARMY
                lda ArrivalTurn,X
                cmp TURN
                bcc _48

                jmp _55

_48             lda OBJX-55,X
                ldy #$03
                sec
                sbc CorpsX,X
                bpl _49

                ldy #$01
                jsr INVERT+2

_49             sty HDIR
                sta HRNGE
                ldy #$00
                lda MoraleCheck2._OBJY-55,X
                sec
                sbc CorpsY,X
                bpl _50

                ldy #$02
                jsr INVERT+2

_50             sty VDIR
                sta VRNGE
                cmp HRNGE
                bcc _51

                sta LRNGE
                lda HRNGE
                sta SRNGE
                lda HDIR
                sta SDIR
                sty LDIR
                jmp _52

_51             sta SRNGE
                sty SDIR
                lda HRNGE
                sta LRNGE
                ldy HDIR
                sty LDIR
_52             lda #$00
                sta RCNT
                sta RORD1
                sta RORD2
                lda LRNGE
                clc
                adc SRNGE
                sta RANGE
                beq _54

                lda LRNGE
                lsr A
                sta CHRIS

_next22         lda CHRIS
                clc
                adc SRNGE
                sta CHRIS
                sec
                sbc RANGE
                bcs _OVRFLO

                lda LDIR
                bcc _STIP

_OVRFLO         sta CHRIS
                lda SDIR
_STIP           sta DIR
                lda RCNT
                and #$03
                tay
                sta TEMPR
                lda RCNT
                lsr A
                lsr A
                tax
                lda DIR
_next23         dey
                bmi _53

                asl A
                asl A
                jmp _next23

_53             ldy TEMPR
                eor RORD1,X
                and MASKO,Y
                eor RORD1,X
                sta RORD1,X
                ldx RCNT
                inx
                stx RCNT
                cpx #$08
                bcs _54

                cpx RANGE
                bcc _next22

_54             ldx ARMY
                lda RORD1
                sta WhatOrders,X
                lda RORD2
                sta WHORDH,X
                lda RCNT
                sta HowManyOrders,X

_55             dex
                cpx #$37                ; when Russian
                bcc _XIT2

                jmp _next21

_XIT2           rts


;======================================
; Calculate individual force ratios
; in all four directions
;======================================
CalculateIFR    .proc
                ldy #$00                ; initialize vectors
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
_next1          lda ArrivalTurn,Y
                cmp TURN
                bcs _1

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
                cmp #$09                ;no point in checking if he's too far
_1              bcs _9

                lsr A
                sta TEMPR               ; this is half of range to unit

;   select which IFR gets this German
                lda TEMPX
                bpl _2

                lda TEMPY
                bpl _4

                ldx #$02
                cmp TEMPX
                bcs _5

                ldx #$01
                bcc _5

_2              lda TEMPY
                bpl _3

                jsr INVERT+2

                ldx #$02
                cmp TEMPX
                bcs _5

                ldx #$03
                bcc _5

_3              ldx #$00
                cmp TEMPX
                bcs _5

                ldx #$03
                bcc _5

_4              lda TEMPX
                jsr INVERT+2

                ldx #$01
                cmp TEMPY
                bcs _5

                ldx #$00
_5              lda CombatStrength,Y
                lsr A
                lsr A
                lsr A
                lsr A
                cpy #$37
                bcc _7

                clc
                adc RFR
                bcc _6

                lda #$FF
_6              sta RFR
                jmp _9

_7              clc
                adc IFR0,X
                bcc _8

                lda #$FF
_8              sta IFR0,X
_9              dey
                beq _10

                jmp _next1

_10             ldx #$03
                lda #$00
_next2          clc
                adc IFR0,X
                bcc _11

                lda #$FF
_11             dex
                bpl _next2

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
_next3          sbc RFR
                bcs _12

                dec IFRHI
                sec
                bmi _13

_12             inx
                jmp _next3

_13             txa
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
                .endproc


;======================================
;
;======================================
INVERT          .proc
                bpl _XIT

                eor #$FF
                clc
                adc #$01
_XIT            rts
                .endproc

;--------------------------------------
;--------------------------------------

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
