;==================================================================
;==================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================


;--------------------------------------
;--------------------------------------
                * = $02_6E00
;--------------------------------------


;--------------------------------------
; Start of Code
;--------------------------------------
START           ldx #$08
_next1          lda ZPVAL,X             ; initialize page zero values
                sta DLSTPT,X
                lda COLTAB,X            ; initialize sprite and playfield colors
                sta LUTSprColor0,X      ; TODO: Sprite-0+ color
                dex
                bpl _next1

                ldx #$0F
_next2          lda PSXVAL,X            ; initialize page six values
                sta XPOSL,X
                dex
                bpl _next2

                lda #$00
                sta X_POS
                sta Y_POS

                .frsGraphics mcGraphicsOn|mcBitmapOn|mcTileMapOn|mcSpriteOn,mcVideoMode640
                .frsMouse_off
                .frsBorder_off

                jsr InitLUT
                jsr InitTiles
                jsr InitMap
                ;jsr InitUnitOverlay
                jsr InitSprites
                jsr InitBitmap


;---
;                .m16i16
; _reset          lda #$00
; _nextXPos       inc A
;                 cmp #160                ;768-640
;                 beq _reset
; _setPos         sta TILE3_WINDOW_X_POS
;                 sta TILE3_WINDOW_Y_POS

;                 ;ldy #$04
; _again          ldx #$800
; _wait           inx
;                 bne _wait

;                 ;dey
;                 ;bne _again

;                 bra _nextXPos
;---

                .m16i16
                lda #$00                ; enable display list & scroll
                sta TILE3_WINDOW_X_POS  ; fine scroll
                sta TILE3_WINDOW_Y_POS

                .m8i8
                ldx #$00
_next3          lda MusterStrength,X    ; combat = muster strength
                sta CombatStrength,X
                lda #$00                ; no orders
                sta HowManyOrders,X

                lda #$FF                ; no execute actions; set turn number to -1
                sta EXEC,X
                inx
                cpx #$A0
                bne _next3

;   here follow various initializations
                lda #12*$10-8   ; 12
                sta SP00_X_POS          ; Sprite-0 x-position
                lda #8*$10-8    ; 8
                sta SP00_Y_POS          ; Sprite-0 y-position

                lda #12*$10-8 
                sta SP01_X_POS
                lda #8*$10-8  
                sta SP01_Y_POS

                lda #12*$10-8 
                sta SP02_X_POS
                lda #9*$10-8  
                sta SP02_Y_POS

;endless         bra endless

                lda #$01
                sta HANDICAP

                lda #$FF
                sta TURN

;   enable deferred vertical blank interrupt
                ;ldy #$00
                ;ldx #$74
                ;lda #$07
                ;jsr SETVBV             ; TODO:platform ; = $7400

                ;lda #$00                ; This is DLI vector (low byte)
                ;sta VDSLST
                ;lda #$7B
                ;sta VDSLST+1
                ;lda #$C0
                ;sta NMIEN              ; Turn interrupts on  ; TODO:platform ; [DLI+VBI]

NewTurn         inc TURN

;   first do calendar calculations
CalendarCalc    lda DAY
                clc
                adc #07
                ldx MONTH
                cmp DaysInMonth,X
                beq _3
                bcc _3

                cpx #$02
                bne _1

                ldy YEAR
                cpy #44
                bne _1

                sec
                sbc #$01
_1              sec
                sbc DaysInMonth,X
                inx
                cpx #13
                bne _2

                inc YEAR
                ldx #01
_2              stx MONTH
                ldy TreeColors,X
                sty TRCOLR
_3              sta DAY
                ldy #$93
                lda #$00
_next1          sta TXTWDW,Y
                iny
                cpy #$A7
                bne _next1

                ldy #$93
                txa
                clc
                adc #$10
                jsr DisplayWord

                lda DAY
                jsr DisplayNumber

                lda #$0C
                sta TXTWDW,Y
                iny
                iny
                lda #$11
                sta TXTWDW,Y
                iny
                lda #$19
                sta TXTWDW,Y
                iny
                ldx YEAR
                lda #$14
                sta TXTWDW,Y
                iny
                lda OnesDigit,X
                clc
                adc #$10
                sta TXTWDW,Y

;   do season calculations
                lda MONTH
                cmp #$04
                bne _4

                lda #$02
                sta EARTH
                lda #$40
                sta SEASN1
                lda #$01
                sta SEASN3
                lda #$00
                sta SEASN2
                jmp ENDSSN

_4              cmp #$0A
                bne _5

                lda #$02
                sta EARTH
                jmp ENDSSN

_5              cmp #$05
                bne _6

                lda #$10
                sta EARTH
                jmp ENDSSN

_6              cmp #$0B
                bne _7

                lda #$0A
                sta EARTH
                jmp _9

_7              cmp #$01
                bne _8

                lda #$80
                sta SEASN1
                lda #$FF
                sta SEASN2
                sta SEASN3
                jmp ENDSSN

_8              cmp #$03
                beq _9

                jmp ENDSSN

;   freeze those rivers, baby
_9              lda SID_RANDOM
                and #$07
                clc
                adc #$07
                eor SEASN2
                sta TEMPR
                lda ICELAT
                sta OLDLAT
                sec
                sbc TEMPR
                beq _10
                bpl _11

_10             lda #$01
_11             cmp #$27
                bcc _12

                lda #$27
_12             sta ICELAT
                lda #$01
                sta CHUNKX
                sta LONGITUDE
                lda OLDLAT
                sta CHUNKY
                sta LATITUDE

_next2          jsr Terrain

                and #$3F
                cmp #$0B
                bcc _15

                cmp #$29
                bcs _15

                ldx CHUNKY
                cpx #$0E
                bcs _13

                cmp #$23
                bcs _15

_13             ora SEASN1
                ldx UNITNO
                beq _14

                sta SWAP,X
                jmp _15

_14             sta (MAPPTR),Y
_15             inc CHUNKX
                lda CHUNKX
                sta LONGITUDE
                cmp #46
                bne _next2

                lda #$00
                sta CHUNKX
                sta LONGITUDE
                lda CHUNKY
                cmp ICELAT
                beq ENDSSN

                sec
                sbc SEASN3
                sta CHUNKY
                sta LATITUDE
                jmp _next2

ENDSSN          ldx #$9E                ; any reinforcements?

_next1          lda ArrivalTurn,X
                cmp TURN
                bne _3

                lda CorpsX,X
                sta CHUNKX
                sta LONGITUDE
                lda CorpsY,X
                sta CHUNKY
                sta LATITUDE
                stx CORPS
                jsr TerrainB
                beq _2

                cpx #$37
                bcs _1

                lda #$0A                ; asterisk character
                sta TXTWDW+36
_1              jsr SwitchCorps

                jmp _3

_2              lda TURN
                clc
                adc #$01
                sta ArrivalTurn,X
_3              dex
                bne _next1

                ldx #$9E
_next2          stx ARMY
                jsr LOGSTC              ; logistics subroutine

                ldx ARMY
                dex
                bne _next2

;   calculate some points
                lda #$00
                sta ACCLO
                sta ACCHI
                ldx #$01
_next3          lda #$30
                sec
                sbc CorpsX,X
                sta TEMPR
                lda MusterStrength,X
                lsr A
                beq _5

                tay
                lda #$00
                clc
_next4          adc TEMPR
                bcc _4

                inc ACCHI
                clc
                bne _4

                dec ACCHI
_4              dey
                bne _next4

_5              inx
                cpx #$37
                bne _next3

_next5          lda CorpsX,X
                sta TEMPR
                lda CombatStrength,X
                lsr A
                lsr A
                lsr A
                beq _7

                tay
                lda #$00
                clc
_next6          adc TEMPR
                bcc _6

                inc ACCLO
                clc
                bne _6

                dec ACCLO
_6              dey
                bne _next6

_7              inx
                cpx #$9E
                bne _next5

                lda ACCHI
                sec
                sbc ACCLO
                bcs _8

                lda #$00
_8              ldx #$03
_next7          ldy MOSCOW,X
                beq _9

                clc
                adc MPTS,X
                bcc _9

                lda #$FF
_9              dex
                bpl _next7

                ldx HANDICAP              ; was handicap option used?
                bne _10                 ; no

                lsr A                   ; yes, halve score
_10             ldy #$05
                jsr DisplayNumber

                lda #$00
                sta TXTWDW,Y
                lda TURN
                cmp #$28
                bne Z00_

                lda #$01                ; end of game
                jsr TextMessage

FINI            bra FINI                ; hang up

Z00_            lda #$00
                sta BUTMSK
                sta CORPS
                jsr TextMessage
                jsr INIT                ; artificial intelligence routine

                lda #$01
                sta BUTMSK
                lda #$02
                jsr TextMessage

;   movement execution phase
                lda #$00
                sta TICK
                ldx #$9E
_next1          stx ARMY
                jsr DINGO               ; determine first execution time

                dex
                bne _next1

_next2          ldx #$9E
_next3          stx ARMY
                lda MusterStrength,X
                sec
                sbc CombatStrength,X
                cmp #$02
                bcc _1

                inc CombatStrength,X
                cmp SID_RANDOM
                bcc _1

                inc CombatStrength,X
_1              lda EXEC,X
                bmi _3

                cmp TICK
                bne _3

                lda WhatOrders,X
                and #$03
                tay
                lda CorpsX,X
                clc
                adc XINC,Y
                sta LONGITUDE
                sta ACCLO
                lda CorpsY,X
                clc
                adc YINC,Y
                sta LATITUDE
                sta ACCHI
                jsr Terrain

                lda UNITNO
                beq _DoMove

                cmp #$37
                bcc _2

                lda ARMY
                cmp #$37
                bcs _nextJam
                bcc _Combat

_2              lda ARMY                ; German
                cmp #$37
                bcs _Combat

_nextJam        ldx ARMY
                lda TICK
                clc
                adc #$02
                sta EXEC,X
_3              jmp _7

_Combat         jsr COMBAT

                lda VICTRY
                beq _3
                bne _4

_DoMove         ldx ARMY
                stx CORPS
                lda CorpsY,X
                sta CHUNKY
                sta LATITUDE
                lda CorpsX,X
                sta CHUNKX
                sta LONGITUDE
                jsr CHKZOC

                lda ACCHI
                sta LATITUDE
                lda ACCLO
                sta LONGITUDE
                lda ZOC
                cmp #$02
                bcc _4

                jsr CHKZOC

                lda ZOC
                cmp #$02
                bcs _nextJam

_4              jsr SwitchCorps

                ldx CORPS
                lda LATITUDE
                sta CHUNKY
                sta CorpsY,X
                lda LONGITUDE
                sta CHUNKX
                sta CorpsX,X
                jsr SwitchCorps

                ldx ARMY
                lda #$FF
                sta EXEC,X
                dec HowManyOrders,X
                beq _7

                lsr WHORDH,X
                ror WhatOrders,X
                lsr WHORDH,X
                ror WhatOrders,X
                ldy #$03
_next4          lda CorpsX,X
                cmp MOSCX,Y
                bne _6

                lda CorpsY,X
                cmp MOSCY,Y
                bne _6

                lda #$FF
                cpx #$37
                bcc _5

                lda #$00
_5              sta MOSCOW,Y
_6              dey
                bpl _next4

                jsr DINGO
                jsr STALL

_7              ldx ARMY
                dex
                beq _8

                jmp _next3

_8              inc TICK
                lda TICK
                cmp #$20
                beq _9

                jmp _next2

;   end of movement phase
_9              jmp NewTurn

;--------------------------------------
;--------------------------------------

MOSCOW          .byte 0,0,0,0

                .byte $22,$50,$a6,$c2,$ca,$f0,$03,$4c,$ff,$70,$ee,$2e
                .byte $06,$ad,$2e,$06,$c9,$20


;--------------------------------------
;--------------------------------------
                * = $02_7200
;--------------------------------------


;======================================
;
;======================================
STALL           lda #$00
_next1          pha
                pla
                pha
                pla
                pha
                pla
                adc #$01
                bne _next1

                rts


;--------------------------------------
; this is the debugging routine
; it can't be reached any longer
;--------------------------------------
ForceDebug      jmp CalendarCalc

;--------------------------------------
;--------------------------------------
                * = $02_7210
;--------------------------------------


;--------------------------------------
;
;--------------------------------------
Break2Monitor   ;lda #$00
                ;sta GRACTL
                ;sta GRAFP0
                ;sta GRAFP1
                ;sta GRAFP2

                ;lda #$22
                ;sta SDMCTL
                ;lda #$20
                ;sta SDLSTL
                ;lda #$BC
                ;sta SDLSTH
                ;lda #$40
                ;sta NMIEN
                ;lda #$0A
                ;sta COLOR1
                ;lda #$00
                ;sta $5FFF
                ;sta COLOR4
                brk                     ; invoke debug monitor
                nop


;--------------------------------------
;--------------------------------------
                * = $02_7240
;--------------------------------------

;======================================
; Determine terrain within a square
;======================================
Terrain         jsr TerrainB
                beq LOOKUP

                rts


;======================================
;
;======================================
TerrainB        lda #$00
                sta MAPPTR+1
                sta UNITNO

                lda #$27
                sec
                sbc LATITUDE
                asl A
                rol MAPPTR+1
                asl A
                rol MAPPTR+1
                asl A
                rol MAPPTR+1
                asl A
                rol MAPPTR+1
                sta TLO
                ldy MAPPTR+1
                sty THI
                asl A
                rol MAPPTR+1
                clc
                adc TLO
                sta MAPPTR

                lda MAPPTR+1
                adc THI
                adc #$65
                sta MAPPTR+1

                lda #46
                sec
                sbc LONGITUDE
                tay
                lda (MAPPTR),Y
                sta TRNCOD
                and #$3F
                cmp #$3D
                beq _XIT

                cmp #$3E
_XIT            rts


;--------------------------------------
;
;--------------------------------------
LOOKUP          lda TRNCOD
                sta UNTCOD
                and #$C0
                ldx #$9E
                cmp #$40
                bne _1

                ldx #$37
_1              lda LATITUDE
_next1          cmp CorpsY,X
                beq _2

_next2          dex
                bne _next1

                lda #$FF
                sta TXTWDW+128
                bmi _match

_2              lda LONGITUDE
                cmp CorpsX,X
                bne _3

                lda CombatStrength,X
                beq _3

                lda ArrivalTurn,X
                bmi _3

                cmp TURN
                bcc _match
                beq _match

_3              lda LATITUDE
                jmp _next2

_match          stx UNITNO
                lda SWAP,X
                sta TRNCOD
                rts


;======================================
; Determine execution time of next move
;======================================
DINGO           ldx ARMY
                lda HowManyOrders,X
                bne Y00

                lda #$FF
                sta EXEC,X
                rts


;======================================
;
;======================================
Y00             lda CorpsX,X
                sta LONGITUDE
                lda CorpsY,X
                sta LATITUDE
                jsr Terrain

                lda UNTCOD
                sta UNTCD1
                ldx ARMY
                lda WhatOrders,X
                eor #$02
                and #$03
                tay
                lda CorpsX,X
                clc
                adc XADD,Y
                sta LONGITUDE
                lda CorpsY,X
                clc
                adc YADD,Y
                sta LATITUDE
                jsr Terrain
                jsr TerrainType

                lda UNTCD1
                and #$3F
                ldx #$00
                cmp #$3D
                beq _2                  ; infantry

                ldx #$0A                ; armor
_2              txa
                ldx MONTH
                clc
                adc SSNCOD-1,X          ; add season index
                adc TRNTYP              ; add terrain index
                tax
                lda TRNTAB,X            ; get net delay
                clc
                adc TICK
                ldx ARMY
                sta EXEC,X
                lda TRNTYP
                cmp #$07
                bcc _XIT

                ldy #$15
_next1          lda LATITUDE
                cmp BHY1,Y
                bne _3

                lda LONGITUDE
                cmp BHX1,Y
                bne _3

                ldx ARMY
                lda CorpsX,X
                cmp BHX2,Y
                bne _3

                lda CorpsY,X
                cmp BHY2,Y
                bne _3

                lda #$FF
                sta EXEC,X
                rts

_3              dey
                bpl _next1

_XIT            rts


;======================================
; Determine type of terrain
;======================================
TerrainType     ldy #$00
                lda TRNCOD
                beq _DONE

                cmp #$7F                ; border?
                bne _1

                ldy #$09
                bne _DONE

_1              iny
                cmp #$07                ; mountain?
                bcc _DONE

                iny
                cmp #$4B                ; city?
                bcc _DONE

                iny
                cmp #$4F                ; frozen swamp?
                bcc _DONE

                iny
                cmp #$69                ; frozen river?
                bcc _DONE

                iny
                cmp #$8F                ; swamp?
                bcc _DONE

                iny
                cmp #$A4                ; river?
                bcc _DONE

                ldx LATITUDE
                cpx #$0E
                bcc _2

                cmp #$A9
                bcc _DONE

_2              iny
                cmp #$BA                ; coastline?
                bcc _DONE

                cpx #$0E
                bcc _3

                cmp #$BB
                bcc _DONE

_3              iny
                cmp #$BD                ; estuary?
                bcc _DONE

                iny
_DONE           sty TRNTYP
                rts

;--------------------------------------
;--------------------------------------

ZPVAL           .word $6400             ; display list address
                .word $0000             ; map address
                .byte $00               ; active corp
                .word $0122             ; cursor x
                .word $0230             ; cursor y

PSXVAL          .byte $E0               ; position x
                .word $0000             ; position y
                .byte $33               ; screen cursor y
                .byte $78               ; player 0 position
                .byte $D6               ; tree color
                .byte $10               ; earth color
                .byte $27               ; ice latitude
                .byte $40,$00,$01       ; season 1-3
                .byte $0F,$06,$29       ; day month year
                .byte $00,$01           ; BUTFLG, BUTMSK

COLTAB          .byte $58,$DC,$2F,$00   ; color table
                .byte $6A,$0C,$94,$46,$B0

MPTS            .byte 20,10,10,10
MOSCX           .byte 20,33,20,6
MOSCY           .byte 28,36,0,15


;======================================
;
;======================================
TextMessage     asl A
                asl A
                asl A
                asl A
                asl A
                tax
                ldy #$69
_next1          lda TxtTbl,X
                sec
                sbc #$20
                sta TXTWDW,Y
                iny
                inx
                txa
                and #$1F
                bne _next1

                rts
