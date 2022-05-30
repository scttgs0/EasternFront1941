;==================================================================
;==================================================================
;EFT VERSION 1.8M (MAINLINE) 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

;
;This is the initialization program
;The program begins here
;


;--------------------------------------
;--------------------------------------
                * = $6E00
;--------------------------------------

START           ldx #$08
BOOP99          lda ZPVAL,X             ; initialize page zero values
                sta DLSTPT,X
                lda COLTAB,X
                sta PCOLR0,X
                dex
                bpl BOOP99

                ldx #$0F
BOOP98          lda PSXVAL,X            ; initialize page six values
                sta XPOSL,X
                dex
                bpl BOOP98

                lda #$00
                sta SDLSTL
                sta HSCROL
                sta VSCROL
                lda DLSTPT+1
                sta SDLSTL+1

                ldx #$00
LOOP22          lda MusterStrength,X
                sta CombatStrength,X
                lda #$00
                sta HowManyOrders,X
                lda #$FF
                sta EXEC,X
                inx
                cpx #$A0
                bne LOOP22

;   set up player window
                lda #$50
                sta PMBASE

;   here follow various initializations
                lda #$2F
                sta SDMCTL
                lda #$03
                sta GRACTL
                lda #$78
                sta HPOSP0
                lda #$01
                sta HANDCP
                sta GPRIOR
                sta SIZEP0
                ldx #$33

                lda #$FF
                sta PLYR0,X
                inx
                sta PLYR0,X
                inx
                lda #$81
LOOP2           sta PLYR0,X
                inx
                cpx #$3F
                bne LOOP2
                lda #$FF
                sta PLYR0,X
                sta TURN
                inx
                sta PLYR0,X

;   enable deferred vertical blank interrupt
                ldy #$00
                ldx #$74
                lda #$07
                jsr SETVBV
                lda #$00                ; This is DLI vector (low byte)
                sta $0200
                lda #$7B
                sta $0201
                lda #$C0
                sta NMIEN               ; Turn interrupts on

NEWTRN          inc TURN

;   first do calendar calculations
                lda DAY
                clc
                adc #07
                ldx MONTH
                cmp DaysInMonth,X
                beq X28
                bcc X28
                cpx #$02
                bne X96
                ldy YEAR
                cpy #44
                bne X96
                sec
                sbc #$01
X96             sec
                sbc DaysInMonth,X
                inx
                cpx #13
                bne X29
                inc YEAR
                ldx #01
X29             stx MONTH
                ldy TreeColors,X
                sty TRCOLR
X28             sta DAY
                ldy #$93
                lda #$00
LOOP13          sta TXTWDW,Y
                iny
                cpy #$A7
                bne LOOP13
                ldy #$93
                txa
                clc
                adc #$10
                jsr DWORDS
                lda DAY
                jsr DNUMBR
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
                bne X87
                lda #$02
                sta EARTH
                lda #$40
                sta SEASN1
                lda #$01
                sta SEASN3
                lda #$00
                sta SEASN2
                jmp ENDSSN
X87             cmp #$0A
                bne X88
                lda #$02
                sta EARTH
                jmp ENDSSN
X88             cmp #$05
                bne X89
                lda #$10
                sta EARTH
                jmp ENDSSN
X89             cmp #$0B
                bne X90
                lda #$0A
                sta EARTH
                jmp X91
X90             cmp #$01
                bne X92
                lda #$80
                sta SEASN1
                lda #$FF
                sta SEASN2
                sta SEASN3
                jmp ENDSSN
X92             cmp #$03
                beq X91
                jmp ENDSSN

;   freeze those rivers, baby
X91             lda RANDOM
                and #$07
                clc
                adc #$07
                eor SEASN2
                sta TEMPR
                lda ICELAT
                sta OLDLAT
                sec
                sbc TEMPR
                beq X95
                bpl X94
X95             lda #$01
X94             cmp #$27
                bcc X93
                lda #$27
X93             sta ICELAT
                lda #$01
                sta CHUNKX
                sta LONG
                lda OLDLAT
                sta CHUNKY
                sta LAT

LOOP40          jsr TERR

                and #$3F
                cmp #$0B
                bcc NOTCH
                cmp #$29
                bcs NOTCH
                ldx CHUNKY
                cpx #$0E
                bcs DOTCH
                cmp #$23
                bcs NOTCH
DOTCH           ora SEASN1
                ldx UNITNO
                beq X86
                sta SWAP,X
                jmp NOTCH
X86             sta (MAPPTR),Y
NOTCH           inc CHUNKX
                lda CHUNKX
                sta LONG
                cmp #46
                bne LOOP40
                lda #$00
                sta CHUNKX
                sta LONG
                lda CHUNKY
                cmp ICELAT
                beq ENDSSN
                sec
                sbc SEASN3
                sta CHUNKY
                sta LAT
                jmp LOOP40

ENDSSN          ldx #$9E                ; any reinforcements?
LOOP14          lda ArrivalTurn,X
                cmp TURN
                bne X33
                lda CorpsX,X
                sta CHUNKX
                sta LONG
                lda CorpsY,X
                sta CHUNKY
                sta LAT
                stx CORPS
                jsr TERRB
                beq SORRY
                cpx #$37
                bcs A51
                lda #$0A
                sta TXTWDW+36
A51             jsr SWITCH
                jmp X33
SORRY           lda TURN
                clc
                adc #$01
                sta ArrivalTurn,X
X33             dex
                bne LOOP14

X31             ldx #$9E
LOOPF           stx ARMY
                jsr LOGSTC              ; logistics subroutine
                ldx ARMY
                dex
                bne LOOPF

;   calculate some points
                lda #$00
                sta ACCLO
                sta ACCHI
                ldx #$01
LOOPB           lda #$30
                sec
                sbc CorpsX,X
                sta TEMPR
                lda MusterStrength,X
                lsr A
                beq A01
                tay
                lda #$00
                clc
LOOPA           adc TEMPR
                bcc A0
                inc ACCHI
                clc
                bne A0
                dec ACCHI
A0              dey
                bne LOOPA
A01             inx
                cpx #$37
                bne LOOPB

LOOPC           lda CorpsX,X
                sta TEMPR
                lda CombatStrength,X
                lsr A
                lsr A
                lsr A
                beq A02
                tay
                lda #$00
                clc
LOOPD           adc TEMPR
                bcc A03
                inc ACCLO
                clc
                bne A03
                dec ACCLO
A03             dey
                bne LOOPD
A02             inx
                cpx #$9E
                bne LOOPC

                lda ACCHI
                sec
                sbc ACCLO
                bcs A04
                lda #$00
A04             ldx #$03
LOOPG           ldy MOSCOW,X
                beq A15
                clc
                adc MPTS,X
                bcc A15
                lda #$FF
A15             dex
                bpl LOOPG

                ldx HANDCP              ; was handicap option used?
                bne A23                 ; no
                lsr A                   ; yes, halve score
A23             ldy #$05
                jsr DNUMBR
                lda #$00
                sta TXTWDW,Y
                lda TURN
                cmp #$28
                bne Z00_
                lda #$01                ; end of game
                jsr TXTMSG
FINI            jmp FINI                ; hang up


Z00_            lda #$00
                sta BUTMSK
                sta CORPS
                jsr TXTMSG
                jsr $4700               ; artificial intelligence routine
                lda #$01
                sta BUTMSK
                lda #$02
                jsr TXTMSG

;   movement execution phase
                lda #$00
                sta TICK
                ldx #$9E
LOOP31          stx ARMY
                jsr DINGO               ; determine first execution time
                dex
                bne LOOP31

LOOP33          ldx #$9E
LOOP32          stx ARMY
                lda MusterStrength,X
                sec
                sbc CombatStrength,X
                cmp #$02
                bcc Y30
                inc CombatStrength,X
                cmp RANDOM
                bcc Y30
                inc CombatStrength,X
Y30             lda EXEC,X
                bmi A60
                cmp TICK
                bne A60
                lda WhatOrders,X
                and #$03
                tay
                lda CorpsX,X
                clc
                adc XINC,Y
                sta LONG
                sta ACCLO
                lda CorpsY,X
                clc
                adc YINC,Y
                sta LAT
                sta ACCHI
                jsr TERR
                lda UNITNO
                beq DOMOVE
                cmp #$37
                bcc GERMAN
                lda ARMY
                cmp #$37
                bcs TRJAM
                bcc COMBAT
GERMAN          lda ARMY
                cmp #$37
                bcs COMBAT
TRJAM           ldx ARMY
                lda TICK
                clc
                adc #$02
                sta EXEC,X
A60             jmp Y06
COMBAT          jsr $4ED8
                lda VICTRY
                beq A60
                bne Z94
DOMOVE          ldx ARMY
                stx CORPS
                lda CorpsY,X
                sta CHUNKY
                sta LAT
                lda CorpsX,X
                sta CHUNKX
                sta LONG
                jsr CHKZOC
                lda ACCHI
                sta LAT
                lda ACCLO
                sta LONG
                lda ZOC
                cmp #$02
                bcc Z94
                jsr CHKZOC
                lda ZOC
                cmp #$02
                bcs TRJAM
Z94             jsr SWITCH
                ldx CORPS
                lda LAT
                sta CHUNKY
                sta CorpsY,X
                lda LONG
                sta CHUNKX
                sta CorpsX,X
                jsr SWITCH
                ldx ARMY
                lda #$FF
                sta EXEC,X
                dec HowManyOrders,X
                beq Y06
                lsr WHORDH,X
                ror WhatOrders,X
                lsr WHORDH,X
                ror WhatOrders,X
                ldy #$03
LOOPH           lda CorpsX,X
                cmp MOSCX,Y
                bne A18
                lda CorpsY,X
                cmp MOSCY,Y
                bne A18
                lda #$FF
                cpx #$37
                bcc A19
                lda #$00
A19             sta MOSCOW,Y
A18             dey
                bpl LOOPH

                jsr DINGO
                jsr STALL
Y06             ldx ARMY
                dex
                beq Y07
                jmp LOOP32
Y07             inc TICK
                lda TICK
                cmp #$20
                beq Y08
                jmp LOOP33

;   end of movement phase
Y08             jmp NEWTRN

;--------------------------------------
;--------------------------------------

MOSCOW          .byte 0,0,0,0

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; added for binary compatibility

                .byte $22,$50,$a6,$c2,$ca,$f0,$03,$4c,$ff,$70,$ee,$2e
                .byte $06,$ad,$2e,$06,$c9,$20
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;--------------------------------------
;--------------------------------------
                * = $7200
;--------------------------------------
STALL           lda #$00
LOOP79          pha
                pla
                pha
                pla
                pha
                pla
                adc #$01
                bne LOOP79
                rts

;
;this is the debugging routine
;it can't be reached by any route any longer
;

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; added for binary compatibility
                jmp $6E9A
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;--------------------------------------
;--------------------------------------
                * = $7210
;--------------------------------------
                lda #$00
                sta $D01D
                sta $D00D
                sta $D00E
                sta $D00F
                lda #$22
                sta $22F
                lda #$20
                sta $230
                lda #$BC
                sta $231
                lda #$40
                sta NMIEN
                lda #$0A
                sta $2C5
                lda #$00
                sta $5FFF
                sta $2C8
                brk


;
;Subroutine TERR determines what terrain is in a square
;

;--------------------------------------
;--------------------------------------
                * = $7240
;--------------------------------------

TERR            jsr TERRB
                beq LOOKUP
                rts
TERRB           lda #$00
                sta MAPPTR+1
                sta UNITNO
                lda #$27
                sec
                sbc LAT
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
                sbc LONG
                tay
                lda (MAPPTR),Y
                sta TRNCOD
                and #$3F
                cmp #$3D
                beq _XIT
                cmp #$3E
_XIT            rts

LOOKUP          lda TRNCOD
                sta UNTCOD
                and #$C0
                ldx #$9E
                cmp #$40
                bne X98
                ldx #$37
X98             lda LAT
LOOP30          cmp CorpsY,X
                beq MIGHTB
X97             dex
                bne LOOP30
                lda #$FF
                sta TXTWDW+128
                bmi MATCH
MIGHTB          lda LONG
                cmp CorpsX,X
                bne X99
                lda CombatStrength,X
                beq X99
                lda ArrivalTurn,X
                bmi X99
                cmp TURN
                bcc MATCH
                beq MATCH
X99             lda LAT
                jmp X97
MATCH           stx UNITNO
                lda SWAP,X
                sta TRNCOD
                rts

;   determines execution time of next move
DINGO           ldx ARMY
                lda HowManyOrders,X
                bne Y00
                lda #$FF
                sta EXEC,X
                rts
Y00             lda CorpsX,X
                sta LONG
                lda CorpsY,X
                sta LAT
                jsr TERR
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
                sta LONG
                lda CorpsY,X
                clc
                adc YADD,Y
                sta LAT
                jsr TERR
                jsr TERRTY
                lda UNTCD1
                and #$3F
                ldx #$00
                cmp #$3D
                beq Y01                 ; infantry
                ldx #$0A                ; armor
Y01             txa
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
                bcc Y02
                ldy #$15
LOOP35          lda LAT
                cmp BHY1,Y
                bne Y03
                lda LONG
                cmp BHX1,Y
                bne Y03
                ldx ARMY
                lda CorpsX,X
                cmp BHX2,Y
                bne Y03
                lda CorpsY,X
                cmp BHY2,Y
                bne Y03
                lda #$FF
                sta EXEC,X
                rts
Y03             dey
                bpl LOOP35
Y02             rts

;
;this subroutine determines the type of terrain
;in a square
;
TERRTY          ldy #$00
                lda TRNCOD
                beq DONE
                cmp #$7F                ; border?
                bne Y04
                ldy #$09
                bne DONE
Y04             iny
                cmp #$07                ; mountain?
                bcc DONE
                iny
                cmp #$4B                ; city?
                bcc DONE
                iny
                cmp #$4F                ; frozen swamp?
                bcc DONE
                iny
                cmp #$69                ; frozen river?
                bcc DONE
                iny
                cmp #$8F                ; swamp?
                bcc DONE
                iny
                cmp #$A4                ; river?
                bcc DONE
                ldx LAT
                cpx #$0E
                bcc NEXT
                cmp #$A9
                bcc DONE
NEXT            iny
                cmp #$BA                ; coastline?
                bcc DONE
                cpx #$0E
                bcc NEXT2
                cmp #$BB
                bcc DONE
NEXT2           iny
                cmp #$BD                ; estuary?
                bcc DONE
                iny
DONE            sty TRNTYP
                rts

;--------------------------------------
;--------------------------------------

ZPVAL           .byte 0,$64,0,0,0,$22,1,$30,2
PSXVAL          .byte $E0,0,0,$33,$78,$D6,$10,$27
                .byte $40,0,1,15,6,41,0,1
COLTAB          .byte $58,$DC,$2F,0,$6A,$C,$94,$46,$B0
MPTS            .byte 20,10,10,10
MOSCX           .byte 20,33,20,6
MOSCY           .byte 28,36,0,15

;--------------------------------------
;--------------------------------------

TXTMSG          asl A
                asl A
                asl A
                asl A
                asl A
                tax
                ldy #$69
LOOP19          lda TxtTbl,X
                sec
                sbc #$20
                sta TXTWDW,Y
                iny
                inx
                txa
                and #$1F
                bne LOOP19
                rts

                .fill 3,$00     ; added for compatibility

            .end
