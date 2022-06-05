;================================================================
;================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;================================================================


;--------------------------------------
;--------------------------------------
                * = $02_4ED8
;--------------------------------------


;======================================
; Combat routine
;======================================
COMBAT          .proc
                lda #$00
                sta VICTRY              ; clear victory flag
                ldx ARMY
                cpx #$2A                ; Finns can't attack
                beq _XIT

                cpx #$2B
                bne _1

_XIT            rts

_1              ldy UNITNO
                sty DEFNDR
                ldx DEFNDR              ; make combat graphics
                lda SWAP,X
                pha
                lda #$FF                ; solid red square
                cpx #$37                ; Russian unit?
                bcs _2

                lda #$7F                ; make it white for Germans
_2              sta SWAP,X
                stx CORPS
                lda CorpsX,X
                sta CHUNKX
                lda CorpsY,X
                sta CHUNKY
                jsr SwitchCorps

                .setbank $AF

                ldy #$08
                ldx #$8F
_next1          stx SID_CTRL1           ; TODO: no distortion; max volume
                sty SID_FREQ1           ; TODO: AUDIO Freq
                jsr STALL

                tya
                clc
                adc #$08
                tay
                dex
                cpx #$7F
                bne _next1

                .setbank $02

;   replace original unit character
                jsr SwitchCorps

                ldx DEFNDR
                pla
                sta SWAP,X


                jsr TerrainType         ; terrain in defender's square

                ldx DEFNC,Y             ; defensive bonus factor
                lda CombatStrength,Y    ; defender's strength
                lsr A
_next2          dex                     ; adjust for terrain
                beq _3

                rol A
                bcc _next2

                lda #$FF

;   adjust for defender's motion
_3              ldx HowManyOrders,Y
                beq _doBattle

                lsr A

;   evaluate defender's strike
_doBattle       cmp SID_RANDOM
                bcc _attacker

                ldx ARMY
                dec MusterStrength,X
                lda CombatStrength,X
                sbc #$05
                sta CombatStrength,X
                beq _4

                bcs _5

_4              jmp Dead                ; attacker dies

_5              jsr MoraleCheck              ; attacker lives; does he break?

;   evaluate attacker's strike
_attacker       ldx ARMY
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
                beq _6

                lsr A                   ; river attack penalty
_6              cmp SID_RANDOM
                bcc _8

                ldx DEFNDR              ; attacker strikes defender
                dec MusterStrength,X
                lda CombatStrength,X
                sbc #$05
                sta CombatStrength,X
                beq _7

                bcs _9

_7              jsr Dead                ; defender dies

_8              jmp _endCombat

_9              jsr MoraleCheck              ; does defender break?

                bcc _8

                ldy ARMY
                lda WhatOrders,Y
                and #$03
                tay                     ; first retreat priority : away from attacker
                jsr Retreat
                bcc _vickory              ; defender died
                beq _12                 ; defender may retreat

                ldy #$01                ; second priority: east/west
                cpx #$37
                bcs _10

                ldy #$03
_10             jsr Retreat
                bcc _vickory
                beq _12

                ldy #$02                ; third priority: north
                jsr Retreat
                bcc _vickory
                beq _12

                ldy #$00                ; fourth priority: south
                jsr Retreat
                bcc _vickory
                beq _12

                ldy #$03                ; last priority: west/east
                cpx #$37
                bcs _11

                ldy #$01
_11             jsr Retreat
                bcc _vickory
                bne _endCombat

_12             stx CORPS               ; retreat the defender
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

_vickory        ldx ARMY
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
_endCombat      ldx ARMY
                inc EXEC,X
                rts
                .endproc


;======================================
; Subroutines for combat
;--------------------------------------
; at entry:
;   X       ID # of defender
;   Y       proposed DIR of retreat
; upon exit:
;   C       bit set if defender lives
;           clear if dies
;   Z       bit set if retreat open
;           clear if blocked
;======================================
Retreat         .proc
                lda CorpsX,X
                clc
                adc XINC,Y
                sta LONGITUDE
                lda CorpsY,X
                clc
                adc YINC,Y
                sta LATITUDE
                jsr Terrain             ; examine terrain
                jsr TerrainType

                ldx DEFNDR
                lda UNITNO              ; anybody in this square?
                bne _3

                lda TRNTYP              ; no

;   check for bad ocean crossings
                cmp #$07                ; coastline?
                bcc _2

                cmp #$09
                beq _3

                ldy #$15
_next1          lda LATITUDE
                cmp BHY1,Y
                bne _1

                lda LONGITUDE
                cmp BHX1,Y
                bne _1

                lda CorpsX,X
                cmp BHX2,Y
                bne _1

                lda CorpsY,X
                cmp BHY2,Y
                beq _3

_1              dey
                bpl _next1

;   any blocking ZOC's?
_2              jsr CheckZOC

                ldx DEFNDR
                lda ZOC
                cmp #$02
                bcs _3                  ; no retreat into ZOC

                lda #$00                ; retreat is possible
                sec
                rts

_3              lda CombatStrength,X    ; retreat not possible,extract penalty
                sec
                sbc #$05
                sta CombatStrength,X
                beq _4

                bcs _5

_4              jsr Dead

                clc
_5              lda #$FF
                rts
                .endproc


;======================================
;   supply evaluation routine
;======================================
Logistics       .proc
                lda ArrivalTurn,X
                cmp TURN
                beq _1
                bcc _1

                rts

_1              lda #$18
                cpx #$37
                bcs _2

                lda #$18
                ldy EARTH
                cpy #$02                ; mud?
                beq _6

                cpy #$0A                ; snow?
                bne _2

                lda CorpsX,X            ; this discourages gung-ho corps
                asl A                   ; double distance
                asl A
                adc #$4A
                cmp SID_RANDOM
                bcc _6

                lda #$10                ; harder to get supplies in winter
_2              sta ACCLO
                ldy #$01                ; Russians go east
                cpx #$37
                bcs _3

                ldy #$03                ; Germans go west
_3              sty HOMEDR
                lda CorpsX,X
                sta LONGITUDE
                lda CorpsY,X
                sta LATITUDE
                lda #$00
                sta RFR
_next1          lda LONGITUDE
                sta SQX
                lda LATITUDE
                sta SQY
_next2          lda SQX
                clc
                adc XINC,Y
                sta LONGITUDE
                lda SQY
                clc
                adc YINC,Y
                sta LATITUDE
                jsr CheckZOC

                cpx #$37
                bcc _4

                jsr TerrainB

                lda TRNCOD
                cmp #$BF
                beq _5

_4              lda ZOC
                cmp #$02
                bcc _8

                inc RFR
_5              inc RFR
                lda RFR
                cmp ACCLO
                bcc _7

_6              lsr CombatStrength,X
                bne _XIT

                jmp Dead

_XIT            rts

_7              lda SID_RANDOM
                and #$02
                tay
                jmp _next2

_8              ldy HOMEDR
                lda LONGITUDE
                cpy #$01
                bne _9

                cmp #$FF
                bne _next1

                inc MusterStrength,X    ; Russian replacements
                inc MusterStrength,X
                rts

_9              cmp #$2E
                bne _next1

                rts
                .endproc


;======================================
; Check for zone of control
;======================================
CheckZOC        .proc
                lda #$00
                sta ZOC
                lda #$40
                cpx #$37
                bcs _1

                lda #$C0
_1              sta TEMPR
                jsr TerrainB
                bne _3

                lda TRNCOD
                and #$C0
                cmp TEMPR
                beq _2

                lda CorpsX,X
                cmp LONGITUDE
                bne _XIT

                lda CorpsY,X
                cmp LATITUDE
                beq _3

_XIT            rts

_2              lda #$02
                sta ZOC
                rts

_3              ldx #$07
_next1          ldy JSTP+16,X
                lda LONGITUDE
                clc
                adc XINC,Y
                sta LONGITUDE
                lda LATITUDE
                clc
                adc YINC,Y
                sta LATITUDE
                jsr TerrainB
                bne _4

                lda TRNCOD
                and #$C0
                cmp TEMPR
                bne _4

                txa
                and #$01
                clc
                adc #$01
                adc ZOC
                sta ZOC
_4              dex
                bpl _next1

                dec LATITUDE
                dec LONGITUDE
                ldx ARMY
                rts
                .endproc


;======================================
;
;======================================
Dead            .proc
                lda #$00
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
                .endproc


;======================================
; Evaluates whether a unit under
; attack breaks
;======================================
MoraleCheck     .proc
                cpx #$37
                bcs _1

                lda CorpType,X
                and #$F0
                bne _1

                lda MusterStrength,X
                lsr A
                jmp _2

_1              lda MusterStrength,X
                lsr A
                lsr A
                lsr A
                sta TEMPR
                lda MusterStrength,X
                sec
                sbc TEMPR
_2              cmp CombatStrength,X
                bcc _XIT

                lda #$FF
                sta EXEC,X
                lda #$00
                sta HowManyOrders,X
_XIT            rts
                .endproc

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;   added for binary compatibility

                .word $A90A

                .fill 384,$00


;======================================
; Evaluates whether a unit under
; attack breaks
;======================================
MoraleCheck2    .proc
                cpx #$47
                bcs _1

                lda CorpType,X
                and #$F0
                bne _1

                lda MusterStrength,X
                lsr A
                jmp _2

_1              lda MusterStrength,X
                lsr A
                lsr A
                lsr A
_OBJY           sta TEMPR
                lda MusterStrength,X
                sec
                sbc TEMPR
_2              cmp CombatStrength,X
                bcs _XIT

                lda #$FF
                sta EXEC,X
                lda #$00
                sta HowManyOrders,X
_XIT            rts
                .endproc

                .fill 41,$00


;======================================
; Evaluates whether a unit under
; attack breaks
;======================================
MoraleCheck4    .proc
                cpx #$47
                bcs _1

                lda CorpType,X
                and #$F0
                bne _1

                lda MusterStrength,X
                lsr A
                jmp _2

_1              lda MusterStrength,X
                lsr A
                lsr A
                lsr A
                sta TEMPR
                lda MusterStrength,X
                sec
                sbc TEMPR
_2              cmp CombatStrength,X
                rts
                .endproc

                .fill 3,$00
