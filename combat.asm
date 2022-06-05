;================================================================
;================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;================================================================


;--------------------------------------
;--------------------------------------
                * = $02_4ED8
;--------------------------------------

;   combat routine
COMBAT          lda #$00
                sta VICTRY              ; clear victory flag
                ldx ARMY
                cpx #$2A                ; Finns can't attack
                beq A10

                cpx #$2B
                bne A11

A10             rts

A11             ldy UNITNO
                sty DEFNDR
                ldx DEFNDR              ; make combat graphics
                lda SWAP,X
                pha
                lda #$FF                ; solid red square
                cpx #$37                ; Russian unit?
                bcs B1

                lda #$7F                ; make it white for Germans
B1              sta SWAP,X
                stx CORPS
                lda CorpsX,X
                sta CHUNKX
                lda CorpsY,X
                sta CHUNKY
                jsr SwitchCorps

                .setbank $AF

                ldy #$08
                ldx #$8F
LOOP78          stx SID_CTRL1           ; TODO: no distortion; max volume
                sty SID_FREQ1           ; TODO: AUDIO Freq
                jsr STALL

                tya
                clc
                adc #$08
                tay
                dex
                cpx #$7F
                bne LOOP78

                .setbank $02

;   replace original unit character
                jsr SwitchCorps

                ldx DEFNDR
                pla
                sta SWAP,X


                jsr TerrainType              ; terrain in defender's square

                ldx DEFNC,Y             ; defensive bonus factor
                lda CombatStrength,Y    ; defender's strength
                lsr A
Y15             dex                     ; adjust for terrain
                beq Y16

                rol A
                bcc Y15

                lda #$FF

;   adjust for defender's motion
Y16             ldx HowManyOrders,Y
                beq DOBATL

                lsr A

;   evaluate defender's strike
DOBATL          cmp SID_RANDOM
                bcc ATAKR

                ldx ARMY
                dec MusterStrength,X
                lda CombatStrength,X
                sbc #$05
                sta CombatStrength,X
                beq Z28

                bcs Y24

Z28             jmp DEAD                ; attacker dies

Y24             jsr BRKCHK              ; attacker lives; does he break?

;   evaluate attacker's strike
ATAKR           ldx ARMY
                lda CorpsX,X
                sta LONGITUDE
                lda CorpsY,X
                sta LATITUDE
                jsr Terrain
                jsr TerrainType

                lda OFFNC,Y
                tay
                ldx ARMY
                lda CombatStrength,X
                dey
                beq Y19

                lsr A                   ; river attack penalty
Y19             cmp SID_RANDOM
                bcc A20

                ldx DEFNDR              ; attacker strikes defender
                dec MusterStrength,X
                lda CombatStrength,X
                sbc #$05
                sta CombatStrength,X
                beq Z29

                bcs Y25

Z29             jsr DEAD                ; defender dies

A20             jmp ENDCOM

Y25             jsr BRKCHK              ; does defender break?

                bcc A20

                ldy ARMY
                lda WhatOrders,Y
                and #$03
                tay                     ; first retreat priority : away from attacker
                jsr RETRET
                bcc VICCOM              ; defender died
                beq Y27                 ; defender may retreat

                ldy #$01                ; second priority: east/west
                cpx #$37
                bcs Y28

                ldy #$03
Y28             jsr RETRET
                bcc VICCOM
                beq Y27

                ldy #$02                ; third priority: north
                jsr RETRET
                bcc VICCOM
                beq Y27

                ldy #$00                ; fourth priority: south
                jsr RETRET
                bcc VICCOM
                beq Y27

                ldy #$03                ; last priority: west/east
                cpx #$37
                bcs Y26

                ldy #$01
Y26             jsr RETRET
                bcc VICCOM
                bne ENDCOM

Y27             stx CORPS               ; retreat the defender
                lda CorpsX,X
                sta CHUNKX
                lda CorpsY,X
                sta CHUNKY
                jsr SwitchCorps

                ldx CORPS
                lda LATITUDE
                sta CorpsY,X
                sta CHUNKY
                lda LONGITUDE
                sta CorpsX,X
                sta CHUNKX
                jsr SwitchCorps

VICCOM          ldx ARMY
                stx CORPS
                lda CorpsX,X
                sta CHUNKX
                lda CorpsY,X
                sta CHUNKY
                lda ACCLO               ;defender's coordinates
                sta LONGITUDE
                lda ACCHI
                sta LATITUDE
                lda #$FF
                sta VICTRY
ENDCOM          ldx ARMY
                inc EXEC,X
                rts

;
;Subroutines for combat
;input: X = ID # of defender. Y = proposed DIR of retreat
;output: C bit set if defender lives, clear if dies
;Z bit set if retreat open, clear if blocked
;
RETRET          lda CorpsX,X
                clc
                adc XINC,Y
                sta LONGITUDE
                lda CorpsY,X
                clc
                adc YINC,Y
                sta LATITUDE
                jsr Terrain                ; examine terrain
                jsr TerrainType

                ldx DEFNDR
                lda UNITNO              ; anybody in this square?
                bne Y22

                lda TRNTYP              ; no

;   check for bad ocean crossings
                cmp #$07                ; coastline?
                bcc Y41

                cmp #$09
                beq Y22

                ldy #$15
LOOP42          lda LATITUDE
                cmp BHY1,Y
                bne Y43

                lda LONGITUDE
                cmp BHX1,Y
                bne Y43

                lda CorpsX,X
                cmp BHX2,Y
                bne Y43

                lda CorpsY,X
                cmp BHY2,Y
                beq Y22

Y43             dey
                bpl LOOP42

;   any blocking ZOC's?
Y41             jsr CHKZOC

                ldx DEFNDR
                lda ZOC
                cmp #$02
                bcs Y22                 ; no retreat into ZOC

                lda #$00                ; retreat is possible
                sec
                rts

Y22             lda CombatStrength,X            ; retreat not possible,extract penalty
                sec
                sbc #$05
                sta CombatStrength,X
                beq Z27

                bcs Y23

Z27             jsr DEAD

                clc
Y23             lda #$FF
                rts

;   supply evaluation routine
LOGSTC          lda ArrivalTurn,X
                cmp TURN
                beq Z86
                bcc Z86

                rts

Z86             lda #$18
                cpx #$37
                bcs A13

                lda #$18
                ldy EARTH
                cpy #$02                ; mud?
                beq A12

                cpy #$0A                ; snow?
                bne A13

                lda CorpsX,X            ; this discourages gung-ho corps
                asl A                   ; double distance
                asl A
                adc #$4A
                cmp SID_RANDOM
                bcc A12

                lda #$10                ; harder to get supplies in winter
A13             sta ACCLO
                ldy #$01                ; Russians go east
                cpx #$37
                bcs Z80

                ldy #$03                ; Germans go west
Z80             sty HOMEDR
                lda CorpsX,X
                sta LONGITUDE
                lda CorpsY,X
                sta LATITUDE
                lda #$00
                sta RFR
LOOP91          lda LONGITUDE
                sta SQX
                lda LATITUDE
                sta SQY
LOOP90          lda SQX
                clc
                adc XINC,Y
                sta LONGITUDE
                lda SQY
                clc
                adc YINC,Y
                sta LATITUDE
                jsr CHKZOC

                cpx #$37
                bcc A80

                jsr TerrainB

                lda TRNCOD
                cmp #$BF
                beq A77

A80             lda ZOC
                cmp #$02
                bcc Z81

                inc RFR
A77             inc RFR
                lda RFR
                cmp ACCLO
                bcc Z84

A12             lsr CombatStrength,X
                bne A50

                jmp DEAD

A50             rts

Z84             lda SID_RANDOM
                and #$02
                tay
                jmp LOOP90

Z81             ldy HOMEDR
                lda LONGITUDE
                cpy #$01
                bne Z85

                cmp #$FF
                bne LOOP91

                inc MusterStrength,X    ; Russian replacements
                inc MusterStrength,X
                rts

Z85             cmp #$2E
                bne LOOP91

                rts

;   routine to check for zone of control
CHKZOC          lda #$00
                sta ZOC
                lda #$40
                cpx #$37
                bcs A70

                lda #$C0
A70             sta TEMPR
                jsr TerrainB
                bne A74

                lda TRNCOD
                and #$C0
                cmp TEMPR
                beq A71

                lda CorpsX,X
                cmp LONGITUDE
                bne A79

                lda CorpsY,X
                cmp LATITUDE
                beq A74

A79             rts

A71             lda #$02
                sta ZOC
                rts

A74             ldx #$07
LOOPQ           ldy JSTP+16,X
                lda LONGITUDE
                clc
                adc XINC,Y
                sta LONGITUDE
                lda LATITUDE
                clc
                adc YINC,Y
                sta LATITUDE
                jsr TerrainB
                bne A75

                lda TRNCOD
                and #$C0
                cmp TEMPR
                bne A75

                txa
                and #$01
                clc
                adc #$01
                adc ZOC
                sta ZOC
A75             dex
                bpl LOOPQ

                dec LATITUDE
                dec LONGITUDE
                ldx ARMY
                rts

DEAD            lda #$00
                sta MusterStrength,X
                sta CombatStrength,X
                sta HowManyOrders,X
                lda #$FF
                sta EXEC,X
                sta ArrivalTurn,X
                stx CORPS
                lda CorpsX,X
                sta CHUNKX
                lda CorpsY,X
                sta CHUNKY
                jsr SwitchCorps

                rts

;
;Subroutine BRKCHK evaluates whether a unit under attack breaks
;
BRKCHK          cpx #$37
                bcs WEAKLG

                lda CorpType,X
                and #$F0
                bne WEAKLG

                lda MusterStrength,X
                lsr A
                jmp Y40

WEAKLG          lda MusterStrength,X
                lsr A
                lsr A
                lsr A
                sta TEMPR
                lda MusterStrength,X
                sec
                sbc TEMPR
Y40             cmp CombatStrength,X
                bcc A30_

                lda #$FF
                sta EXEC,X
                lda #$00
                sta HowManyOrders,X
A30_             rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;   added for binary compatibility

                .word $A90A

                .fill 384,$00

;
;Subroutine BRKCHK2 evaluates whether a unit under attack breaks
;
BRKCHK2         cpx #$47
                bcs WEAKLG2

                lda CorpType,X
                and #$F0
                bne WEAKLG2

                lda MusterStrength,X
                lsr A
                jmp Y40_2

WEAKLG2         lda MusterStrength,X
                lsr A
                lsr A
                lsr A
OBJY            sta TEMPR
                lda MusterStrength,X
                sec
                sbc TEMPR
Y40_2           cmp CombatStrength,X
                bcs A30_2

                lda #$FF
                sta EXEC,X
                lda #$00
                sta HowManyOrders,X
A30_2           rts

                .fill 41,$00

;
;Subroutine BRKCHK3 evaluates whether a unit under attack breaks
;
BRKCHK4         cpx #$47
                bcs WEAKLG3

                lda CorpType,X
                and #$F0
                bne WEAKLG3

                lda MusterStrength,X
                lsr A
                jmp Y40_3

WEAKLG3         lda MusterStrength,X
                lsr A
                lsr A
                lsr A
                sta TEMPR
                lda MusterStrength,X
                sec
                sbc TEMPR
Y40_3           cmp CombatStrength,X
                rts

                .fill 3,$00

            .end
