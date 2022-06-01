;===================================================================
;===================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;===================================================================


;--------------------------------------
;--------------------------------------
                * = $5200
;--------------------------------------
PLYR0           .fill 128               ; cursor
PLYR1           .fill 128               ; movement arrow
PLYR2           .fill 128               ; maltese cross

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                * = $7400               ; deferred vertical blank interrupt
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;   debug entry
                ;lda JOYSTICK1          ; read joystick1 button (check for break button)
                ;and #$10
                lda #$FF                ; force break to be ignored
                nop

                bne Z30                 ; no, check next
;   end debug entry

;   start debug mode
                ldy #$3E                ; reset 60 Hertz vector
                ldx #$E9
                lda #7
                jsr SETVBV  ; TODO:platform ; restore VBLANK EXIT routine

                pla                     ; reset stack
                pla
                pla
                jmp $7210               ; break routine

Z30             lda HANDCP
                beq A31

                lda JOYSTICK0           ; read joystick0 button
                and #$10
                beq A31

                lda #$08
                sta CONSOL  ; TODO:platform     ; reset function keys
                lda CONSOL  ; TODO:platform     ; read function keys
                and #$04                ; OPTION key
                bne A31

                sta HANDCP
                lda #$30
                sta $7B7A               ; my trademark
                ldx #$36
LOOPJ           lda MusterStrength,X
                sta TEMPI
                lsr A
                adc TEMPI
                bcc A22

                lda #$FF
A22             sta MusterStrength,X
                dex
                bne LOOPJ

A31             lda JOYSTICK0           ; read joystick0 button
                and #$10
                ora BUTMSK              ; button allowed?
                beq X17

                lda BUTFLG              ; no button now; previous status
                bne X23

                jmp NOBUT

X23             lda #$58                ; button just released
                sta PCOLR0  ; TODO:platform     ; P/M-0 color
                lda #$00
                sta BUTFLG
                sta KRZFLG
                sta AUDC1  ; TODO:platform  ; no distortion; no volume
                ldx #$52
LOOP8           sta TXTWDW+8,X          ; clear text window
                dex
                bpl LOOP8

                lda #$08
                sta DELAY
                clc
                adc RTCLOK  ; TODO:platform
                sta TIMSCL
                jsr SWITCH

                lda #$00
                sta CORPS
                jsr CLRP1
                jsr CLRP2

                jmp ENDISR

X17             lda JOYSTICK0           ; button is pressed - joystick0 read
                and #$0F
                eor #$0F
                beq X20                 ; joystick active?

                jmp ORDERS              ; yes

X20             sta DBTIMR              ; no, set debounce
                sta AUDC1  ; TODO:platform  ; distortion/volume
                sta STKFLG
                lda BUTFLG
                bne BUTHLD              ; is this the first button pass

                jmp FBUTPS              ; yes

BUTHLD          jsr ERRCLR              ; no, clear errors

X61             lda HITFLG
                beq X63                 ; anybody in the window?

                jmp ENDISR              ; no

X63             lda KEYCHAR             ; last key pressed
                cmp #$21
                bne X80                 ; space bar pressed?

                ldx CORPS               ; yes, check for Russian
                cpx #$37
                bcs X80

                lda #$00
                sta KEYCHAR             ; last key pressed
                sta HowManyOrders,X     ; clear out orders
                sta HOWMNY
                sta STPCNT
                lda #$01
                sta ORDCNT
                jsr CLRP1
                jsr CLRP2

                lda BASEX
                sta STEPX
                lda BASEY
                sta STEPY
X80             lda RTCLOK  ; TODO:platform
                and #$03
                beq X54                 ; time to move arrow?

                jmp ENDISR              ; no

X54             ldy HOWMNY              ; yes
                bne X65                 ; any orders to show?

                jmp PCURSE              ; no, go ahead to maltakreuze

X65             jsr CLRP1               ; yes, clear old arrow

                lda ORDCNT
                ldx #$00                ; assume first byte
                cmp #$05
                bcc X52                 ; second byte or first?

                inx                     ; second byte
X52             and #$03                ; isolate bit pair index
                tay
                lda BITTAB,Y            ; get mask
X50             and ORD1,X              ; get orders

;   right justify orders
                dey
                bpl X51

                ldy #$03
X51             beq X53

LOOP21          lsr A
                lsr A
                dey
                bne LOOP21

X53             sta ARRNDX
                asl A
                asl A
                asl A

;   get arrow image and store it to player RAM
                tax
                ldy STEPY
X55             lda ArrowTbl,X
                cpy #$80
                bcs X43

                sta PLYR1,Y
X43             inx
                iny
                txa
                and #$07
                bne X55

                lda STEPX               ; position arrow
                sta HPOSP1  ; TODO:platform     ; P/M-1 x-position

;   now step arrow
                ldx ARRNDX
                lda STEPX
                clc
                adc XADD,X
                sta STEPX
                lda STEPY
                clc
                adc YADD,X
                sta STEPY

                inc STPCNT              ; next step
                lda STPCNT
                and #$07
                bne X59                 ; if not done end ISR

                sta STPCNT              ; end of steps
                inc ORDCNT              ; next order
                lda ORDCNT
                cmp HOWMNY              ; last order?
                bcc X59                 ; no, out
                beq X59                 ; no, out

                lda #$01
                sta ORDCNT              ;yes, reset to start of arrow's path

;   display maltese cross ('maltakreuze' or KRZ)
PCURSE          ldy STEPY
                sty KRZY
                lda #$FF
                sta KRZFLG
                ldx #$00
LOOP24          lda MLTKRZ,X
                cpy #$80
                bcs X44

                sta PLYR2,Y
X44             iny
                inx
                cpx #$08
                bne LOOP24

                lda STEPX
                sec
                sbc #$01
                sta KRZX
                sta HPOSP2  ; TODO:platform     ; P/M-2 x-position
                jsr CLRP1               ; clear arrow

                lda BASEX               ; reset arrow's coords
                sta STEPX
                lda BASEY
                sta STEPY

X59             jmp ENDISR

;
;FIRST BUTTON PASS
;looks for a unit inside cursor
;if there is one, puts unit info into text window
;
FBUTPS          lda #$FF
                sta BUTFLG

;   first get coords of center of cursor (map frame)
X24             lda CURSXL
                clc
                adc #$06
                sta TXL
                lda CURSXH
                adc #$00
                sta TXH
                lda CURSYL
                clc
                adc #$09
                sta TYL
                lda CURSYH
                adc #$00
                sta TYH
                lda TXH
                lsr A
                lda TXL
                ror A
                lsr A
                lsr A

;   coords of cursor (pixel frame)
                sta CHUNKX
                lda TYH
                lsr A
                tax
                lda TYL
                ror A
                tay
                txa
                lsr A
                tya
                ror A
                lsr A
                lsr A
                sta CHUNKY

;   look for a match with unit coordinates
                ldx #$9E
LOOP6           cmp CorpsY,X
                beq MAYBE

X16             dex
                bne LOOP6

                stx CORPS               ; no match obtained
                dex
                stx HITFLG
                jmp ENDISR

MAYBE           lda CHUNKX
                cmp CorpsX,X
                bne X35

                lda ArrivalTurn,X
                bmi X35

                cmp TURN
                bcc MATCH_
                beq MATCH_

X35             lda CHUNKY
                jmp X16


;   match obtained
MATCH_          lda #$00
                sta HITFLG              ; note match
                sta KEYCHAR             ; last key pressed
                lda #$5C
                sta PCOLR0              ; light up cursor  ; TODO:platform     ; P/M-0 color

;   display unit specs
                stx CORPS
                ldy #$0D
                lda CorpNumber,X        ; ID number
                jsr DNUMBR

                iny
                ldx CORPS
                lda CorpType,X          ; first name
                sta TEMPI
                and #$F0
                lsr A
                jsr ENTRY2

                lda TEMPI
                and #$0F                ; second name
                clc
                adc #$08
                jsr DWORDS

                lda #$1E
                ldx CORPS
                cpx #$37
                bcs X26

                lda #$1D
X26             jsr DWORDS              ; display unit size (corps or army)

                ldy #$38
                lda #$1F                ; "MUSTER"
                jsr DWORDS

                dey
                lda #$1A                ; ":"
                sta TXTWDW,Y
                iny
                iny
                ldx CORPS
                lda MusterStrength,X    ; muster strength
                jsr DNUMBR

                iny
                iny
                lda #$20                ; "COMBAT"
                jsr DWORDS

                lda #$21                ; "STRENGTH"
                jsr DWORDS

                dey
                lda #$1A                ; ":"
                sta TXTWDW,Y
                iny
                iny
                ldx CORPS
                lda CombatStrength,X    ; combat strength
                jsr DNUMBR
X27             jsr SWITCH              ; flip unit with terrain

                lda CORPS
                cmp #$37
                bcc X79                 ; Russian?

                lda #$FF                ; yes, mask orders and exit
                sta HITFLG
                bmi X75

;
;German unit
;set up orders display
;first calculate starting coords (BASEX, BASEY)
;
X79             lda #$01
                sta ORDCNT
                lda #$00
                sta STPCNT

                lda TXL
                and #$07
                clc
                adc #$01
                clc
                adc SHPOS0
                sta BASEX
                sta STEPX

                lda TYL
                and #$0F
                lsr A
                sec
                sbc #$01
                clc
                adc SCY
                sta BASEY
                sta STEPY

;   set up page 6 values
                ldx CORPS
                lda HowManyOrders,X
                sta HOWMNY
                lda WhatOrders,X
                sta ORD1
                lda WHORDH,X
                sta ORD2
X75             jmp ENDISR

;
;ORDERS INPUT ROUTINE
;
ORDERS          lda STKFLG
                bne X75

                ldx CORPS
                cpx #$37
                bcc X64                 ; Russian?

                ldx #$00                ; yes, error
                jmp SQUAWK

X64             lda HowManyOrders,X
                cmp #$08
                bcc X66                 ; only 8 orders allowed

                ldx #$20
                jmp SQUAWK

X66             lda KRZFLG
                bne X67                 ; must wait for maltakreuze

                ldx #$40
                jmp SQUAWK

X67             inc DBTIMR
                lda DBTIMR              ; wait for debounce time
                cmp #$10
                bcs X68

                bcc X75

X68             lda #$00
                sta DBTIMR              ; reset debounce timer
                lda JOYSTICK0           ; joystick0 read
                and #$0F
                tax
                lda STKTAB,X
                bpl X69

                ldx #$60                ; no diagonal orders allowed
                jmp SQUAWK

;   OK, this is a good order
X69             tay
                sta STICKI
                lda BEEPTB,Y
                sta AUDF1               ; "BEEP!"  ; TODO:platform  ; AUDIO Freq
                lda #$A8
                sta AUDC1  ; TODO:platform  ; distortion-5; half volume
                lda #$FF
                sta STKFLG

                ldx CORPS
                inc HowManyOrders,X
                lda HowManyOrders,X
                sta HOWMNY
                sec
                sbc #$01
                and #$03
                tay
                sty TEMPI
                lda HowManyOrders,X
                sec
                sbc #$01
                lsr A
                lsr A
                tax
                lda STICKI

;   isolate order
X71             dey
                bmi X70

                asl A
                asl A
                jmp X71

X70             ldy TEMPI
                eor ORD1,X              ; fold in new order (sneaky code)
                and MASKO,Y
                eor ORD1,X
                sta ORD1,X
                lda ORD1
                ldx CORPS
                sta WhatOrders,X
                lda ORD2
                sta WHORDH,X

;   move maltakreuze
                jsr CLRP2

                ldx STICKI
                lda KRZX
                clc
                adc XOFF,X
                sta KRZX
                lda KRZY
                clc
                adc YOFF,X
                sta KRZY
DSPKRZ          lda KRZX                ; display it
                sta HPOSP2  ; TODO:platform     ; P/M-2 x-position
                ldy KRZY
                ldx #$00
LOOP26          lda MLTKRZ,X
                cpy #$80
                bcs X45

                sta PLYR2,Y
X45             iny
                inx
                cpx #$08
                bne LOOP26
                beq EXITI

;
;ERROR on inputs routine
;squawks speaker and puts out error message
;
SQUAWK          ldy #$69
LOOP28          lda ERRMSG,X
                sec
                sbc #$20
                sta TXTWDW,Y
                iny
                inx
                txa
                and #$1F
                bne LOOP28

                lda #$68
                sta AUDC1  ; TODO:platform  ; distortion-3; half volume
                lda #$50
                sta AUDF1               ; "HONK!"  ; TODO:platform  ; AUDIO Freq
                lda #$FF
                sta ERRFLG
                bmi EXITI

;
;NO BUTTON PRESSED ROUTINE
;
NOBUT           sta DBTIMR
                lda JOYSTICK0           ; joystick0 read
                and #$0F
                eor #$0F
                bne SCROLL

                sta AUDC1  ; TODO:platform      ; no distortion; volume set based on joystick movement
                sta STKFLG
                lda #$08
                sta DELAY
                clc
                adc RTCLOK  ; TODO:platform
                sta TIMSCL
                jsr ERRCLR

EXITI           jmp ENDISR

;   acceleration feature of cursor
SCROLL          lda TIMSCL
                cmp RTCLOK  ; TODO:platform
                bne EXITI

                lda DELAY
                cmp #$01
                beq X21

                sec
                sbc #$01
                sta DELAY
X21             clc
                adc RTCLOK  ; TODO:platform
                sta TIMSCL

                lda #$00
                sta OFFLO
                sta OFFHI               ; zero the offset

                lda JOYSTICK0           ; joystick0 read
                and #$0F
                pha                     ; save it on stack for other bit checks
                and #$08                ; joystick left?
                bne CHKRT               ; no, move on

                lda CURSXL
                bne X13

                ldx CURSXH
                beq CHKUP

X13             sec
                sbc #$01
                sta CURSXL
                bcs X14

                dec CURSXH
X14             lda SHPOS0
                cmp #$BA
                beq X1

                clc
                adc #$01
                sta SHPOS0
                sta HPOSP0  ; TODO:platform     ; P/M-0 x-position
                bne CHKUP

X1              lda XPOSL
                sec                     ; decrement x-coordinate
                sbc #$01
                sta XPOSL
                and #$07
                sta HSCROL              ; fine scroll  ; TODO:platform
                cmp #$07                ; scroll overflow?
                bne CHKUP               ; no, move on

                inc OFFLO               ; yes, mark it for offset
                clv
                bvc CHKUP               ; no point in checking for joystick right

CHKRT           pla                     ; get back joystick byte
                pha                     ; save it again
                and #$04                ; joystick right?
                bne CHKUP               ; no, move on

                lda CURSXL
                cmp #$64
                bne X12

                ldx CURSXH
                bne CHKUP

X12             clc
                adc #$01
                sta CURSXL
                bcc X15

                inc CURSXH
X15             lda SHPOS0
                cmp #$36
                beq X2

                sec
                sbc #$01
                sta SHPOS0
                sta HPOSP0  ; TODO:platform     ; P/M-0 x-position
                bne CHKUP

X2              lda XPOSL
                clc                     ; no, increment x-coordinate
                adc #$01
                sta XPOSL
X4              and #$07
                sta HSCROL              ; fine scroll  ; TODO:platform
                bne CHKUP               ; scroll overflow? if not, move on

                dec OFFLO               ; yes, set up offset for character scroll
                dec OFFHI
CHKUP           pla                     ; joystick up?
                lsr A
                pha
                bcs CHKDN               ; no, ramble on

                lda CURSYL
                cmp #$5E
                bne X3

                ldx CURSYH
                cpx #$02
                beq CHKDN

X3              inc CURSYL
                bne X11

                inc CURSYH
X11             ldx SCY
                cpx #$1B
                beq X6

                inc CURSYL
                bne X18

                inc CURSYH
X18             dex
                stx SCY
                txa
                clc
                adc #$12
                sta TEMPI
LOOP4           lda PLYR0,X
                sta PLYR0-1,X
                inx
                cpx TEMPI
                bne LOOP4
                beq CHKDN

X6              lda YPOSL
                sec
                sbc #$01
                bcs X7

                dec YPOSH
X7              sta YPOSL
                and #$0F
                sta VSCROL              ; fine scroll  ; TODO:platform
                cmp #$0F
                bne CHKDN               ; scroll overflow? If not, amble on

                lda OFFLO               ; yes, set up offset for character scroll
                sec
                sbc #$30
                sta OFFLO
                lda OFFHI
                sbc #$00
                sta OFFHI
CHKDN           pla                     ; joystick down?
                lsr A
                bcs CHGDL               ; no, trudge on

                lda CURSYL
                cmp #$02
                bne X5

                ldx CURSYH
                beq CHGDL

X5              sec
                sbc #$01
                sta CURSYL
                bcs X10

                dec CURSYH
X10             ldx SCY
                cpx #$4E
                beq X8

                sec
                sbc #$01
                sta CURSYL
                bcs X19

                dec CURSYH
X19             inx
                stx SCY
                txa
                clc
                adc #$12
                dex
                dex
                stx TEMPI
                tax
LOOP5           lda PLYR0-1,X
                sta PLYR0,X
                dex
                cpx TEMPI
                bne LOOP5
                beq CHGDL

X8              lda YPOSL
                clc                     ; no, decrement y-coordinate
                adc #$01
                sta YPOSL
                bcc X9

                inc YPOSH
X9              and #$0F
                sta VSCROL              ; fine scroll  ; TODO:platform
                bne CHGDL               ; no, move on

                lda OFFLO               ; yes, mark offset
                clc
                adc #$30
                sta OFFLO
                lda OFFHI
                adc #$00
                sta OFFHI

;
;In this loop we add the offset values to the existing
;LMS addresses of all display lines.
;This scrolls the characters.
;
CHGDL           ldy #$09
DLOOP           lda (DLSTPT),Y
                clc
                adc OFFLO
                sta (DLSTPT),Y
                iny
                lda (DLSTPT),Y
                adc OFFHI
                sta (DLSTPT),Y
                iny
                iny
                cpy #$27
                bne DLOOP

ENDISR          lda YPOSH
                lsr A
                lda YPOSL
                ror A
                lsr A
                lsr A
                lsr A
                cmp #$11
                bcs X39

                lda #$FF
                bmi X40

X39             cmp #$1A
                bcc X41

                lda #$02
                bpl X40

X41             sta TEMPI
                inx
                lda #$1D
                sec
                sbc TEMPI
X40             sta CNT1
                lda #$00
                sta CNT2
                jmp XITVBV              ; exit vertical blank routine  ; TODO:platform

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; added for binary compatibility
                .byte $E4
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;--------------------------------------
;--------------------------------------
                * = $799C
;--------------------------------------
JSTP            .byte 0,0,0,0,3,3,3,3
                .byte 2,2,2,2,1,1,1,0
                .byte 0,0,3,3,2,2,1,0
DEFNC           .byte 2,3,3,2,2,2,1,1,2,0

;--------------------------------------
;--------------------------------------
                * = $79C0
;--------------------------------------
;
;SUBROUTINE DWORDS
;displays a single word from a long table of words
;
DWORDS          asl A
                asl A
                asl A
                bcc ENTRY2

                tax
BOOP20          lda WordsTbl+256,X
                sec
                sbc #$20
                beq BNDW

                sta TXTWDW,Y
                iny
                inx
                txa
                and #$07
                bne BOOP20

BNDW            iny
                rts

ENTRY2          tax                     ; this is another entry point
LOOP20          lda WordsTbl,X
                sec
                sbc #$20
                beq NDW

                sta TXTWDW,Y
                iny
                inx
                txa
                and #$07
                bne LOOP20

NDW             iny
                rts

;
;SUBROUTINE SWITCH FOR SWAPPING CORPS WITH TERRAIN
;
SWITCH          lda #$00
                sta MAPHI
                lda #$27
                sec
                sbc CHUNKY
                asl A
                rol MAPHI
                asl A
                rol MAPHI
                asl A
                rol MAPHI
                asl A
                rol MAPHI
                sta TEMPLO
                ldx MAPHI
                stx TEMPHI
                asl A
                rol MAPHI
                clc
                adc TEMPLO
                sta MAPLO
                lda MAPHI
                adc TEMPHI
                adc #$65
                sta MAPHI
                lda #46
                sec
                sbc CHUNKX
                tay
                lda (MAPLO),Y
                ldx CORPS
                beq X34

                pha
                lda SWAP,X
                sta (MAPLO),Y
                pla
                sta SWAP,X
X34             rts

;
;SUBROUTINE CLRP1
;clears the arrow player
;
CLRP1           lda #$00
                ldy STEPY
                dey
                tax
LOOP23          cpy #$80
                bcs X22

                sta PLYR1,Y
X22             iny
                inx
                cpx #$0B
                bne LOOP23

                rts

;
;SUBROUTINE CLRP2
;clears the maltakreuze
;
CLRP2           lda #$00
                ldy KRZY
                tax
LOOP25          cpy #$80
                bcs X42

                sta PLYR2,Y
X42             iny
                inx
                cpx #$0A
                bne LOOP25

                rts

;
;SUBROUTINE ERRCLR
;clears sound and the text window
;
ERRCLR          lda ERRFLG
                bpl ENDERR

                lda #$00
                sta ERRFLG
                ldy #$86
                ldx #$1F
LOOP29          sta TXTWDW,Y
                dey
                dex
                bpl LOOP29

ENDERR          rts

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

;
;From here to $7B00 is expansion RAM
;

;
;This is the DLI routine
;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                * = $7B00
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLISRV          pha
                txa
                pha
                inc CNT2
                lda CNT2
                cmp CNT1
                bne OVER1

                ldx #$62                ; map DLI
                lda #$28
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                sta WSYNC  ; TODO:platform
                stx CHBASE  ; TODO:platform     ; charset = $6200
                sta COLPF0  ; TODO:platform     ; playfield-0 color
                jmp DLIOUT

OVER1           cmp #$0F
                bne OVER6

                lda #$3A
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                tax
                lda #$00
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                sta WSYNC  ; TODO:platform
                stx COLPF2  ; TODO:platform     ; playfield-2 color
                sta COLPF1  ; TODO:platform     ; playfield-1 color
                jmp DLIOUT

OVER6           cmp #$01
                bne OVER2

                lda TRCOLR              ; green tree color
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                tax
                lda #$1A                ; yellow band at top of map
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                sta WSYNC  ; TODO:platform
                sta COLBAK  ; TODO:platform     ; background color
                stx COLPF0  ; TODO:platform     ; playfield-0 color
                lda #$60
                sta CHBASE  ; TODO:platform     ; charset = $6000
                jmp DLIOUT

OVER2           cmp #$03
                bne OVER3

                lda EARTH               ; top of map
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                sta WSYNC  ; TODO:platform
                sta COLBAK  ; TODO:platform     ; background color
                jmp DLIOUT

OVER3           cmp #$0D
                bne OVER4

                ldx #$E0                ; bottom of map
                lda #$22
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                sta WSYNC  ; TODO:platform
                sta COLPF2  ; TODO:platform     ; playfield-2 color
                stx CHBASE  ; TODO:platform     ; charset = standard OS charset
                jmp DLIOUT

OVER4           cmp #$0E
                bne OVER5

                lda #$8A                ; bright blue strip
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                sta WSYNC  ; TODO:platform
                sta COLBAK  ; TODO:platform     ; background color
                jmp DLIOUT

OVER5           cmp #$10
                bne DLIOUT

                lda #$D4                ; green bottom
                ;eor COLRSH  ; TODO:platform
                ;and DRKMSK  ; TODO:platform
                pha                     ; some extra delay
                pla
                nop
                sta COLBAK  ; TODO:platform     ; background color

DLIOUT          pla
                tax
                pla
                rti

;
;SUBROUTINE DNUMBR
;displays a number with leading zero suppress
;
DNUMBR          tax
                clc
                lda HundredDigit,X
                beq X36

                adc #$10
                sta TXTWDW,Y
                iny
                sec
X36             lda TensDigit,X
                bcs X38
                beq X37

X38             clc
                adc #$10
                sta TXTWDW,Y
                iny
X37             lda OnesDigit,X
                clc
                adc #$10
                sta TXTWDW,Y
                iny
                rts

;--------------------------------------
;--------------------------------------

NDX             .byte 0,1,2,3,4,9,14,19
                .byte 24,23,22,21,20,15,10,5
                .byte 6,7,8,13,18,17,16,11
YINC            .byte 1
XINC            .byte 0,$FF,0,1
OFFNC           .byte 1,1,1,1,1,1,2,2,1,0

            .end
