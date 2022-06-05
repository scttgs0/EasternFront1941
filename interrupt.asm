;===================================================================
;===================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;===================================================================


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Deferred vertical blank interrupt
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;   debug entry
DVBI            ;lda JOYSTICK1          ; read joystick1 button (check for break button)
                ;and #$10
                lda #$FF                ; force break to be ignored
                nop
                bne _1                  ; no, check next

;   end debug entry

;   start debug mode
                ;ldy #$3E               ; reset 60 Hertz vector
                ;ldx #$E9
                ;lda #7
                ;jsr SETVBV             ; TODO:platform ; restore VBLANK EXIT routine

                ;pla                    ; reset stack
                ;pla
                ;pla
                ;jmp Break2Monitor      ; break routine

_1              lda HANDICAP
                beq _3                  ; skip when handicap

                lda JOYSTICK0           ; read joystick0 button
                and #$10
                beq _3                  ; skip when button is pressed

                lda #$08
                sta CONSOL              ; TODO: reset function keys
                lda CONSOL              ; TODO: read function keys
                and #$04                ; OPTION key
                bne _3

                sta HANDICAP
                lda #$30
                sta $7B7A               ; my trademark
                ldx #$36
_next1          lda MusterStrength,X
                sta TEMPI
                lsr A
                adc TEMPI
                bcc _2

                lda #$FF
_2              sta MusterStrength,X
                dex
                bne _next1

_3             lda JOYSTICK0            ; read joystick0 button
                and #$10
                ora BUTMSK              ; button allowed?
                beq _5

                lda BUTFLG              ; no button now; previous status
                bne _4

                jmp NoButton

_4              lda #$58                ; button just released
                sta LUTSprColor0        ; TODO: Sprite-0 color
                lda #$00
                sta BUTFLG
                sta KRZFLG
                sta SID_CTRL1           ; TODO: no distortion; no volume
                ldx #$52
_next2          sta TXTWDW+8,X          ; clear text window
                dex
                bpl _next2

                lda #$08
                sta DELAY
                clc
                adc JIFFYCLOCK          ; TODO:
                sta TIMSCL
                jsr SwitchCorps

                lda #$00
                sta CORPS
                jsr ClearArrow
                jsr ClearMaltakreuze

                jmp ENDISR

_5              lda JOYSTICK0           ; button is pressed - joystick0 read
                and #$0F
                eor #$0F
                beq _6                  ; joystick active?

                jmp ORDERS              ; yes

_6              sta DBTIMR              ; no, set debounce
                sta SID_CTRL1           ; TODO: distortion/volume
                sta STKFLG
                lda BUTFLG
                bne _7                  ; is this the first button pass

                jmp FirstBtnPass        ; yes

_7              jsr ERRCLR              ; no, clear errors

                lda HITFLG
                beq _8                  ; anybody in the window?

                jmp ENDISR              ; no

_8              lda KEYCHAR             ; last key pressed
                cmp #$21
                bne _9                  ; space bar pressed?

                ldx CORPS               ; yes, check for Russian
                cpx #$37                ; when Russian
                bcs _9

                lda #$00
                sta KEYCHAR             ; last key pressed
                sta HowManyOrders,X     ; clear out orders
                sta HOWMNY
                sta STPCNT
                lda #$01
                sta ORDCNT
                jsr ClearArrow
                jsr ClearMaltakreuze

                lda BASEX
                sta STEPX
                lda BASEY
                sta STEPY
_9             lda JIFFYCLOCK           ; TODO:
                and #$03
                beq _10                 ; time to move arrow?

                jmp ENDISR              ; no

_10             ldy HOWMNY              ; yes
                bne _11                 ; any orders to show?

                jmp _printCursor        ; no, go ahead to maltakreuze

_11             jsr ClearArrow          ; yes, clear old arrow

                lda ORDCNT
                ldx #$00                ; assume first byte
                cmp #$05
                bcc _12                 ; second byte or first?

                inx                     ; second byte
_12             and #$03                ; isolate bit pair index
                tay
                lda BITTAB,Y            ; get mask
                and ORD1,X              ; get orders

;   right justify orders
                dey
                bpl _13

                ldy #$03
_13             beq _14

_next3          lsr A
                lsr A
                dey
                bne _next3

_14             sta ARRNDX
                asl A
                asl A
                asl A

;   get arrow image and store it to player RAM
                tax
                ldy STEPY
_next4          lda ArrowTbl,X
                cpy #$80
                bcs _15

                .setbank $05
                sta PLYR1,Y
                .setbank $03
_15             inx
                iny
                txa
                and #$07
                bne _next4

                lda STEPX               ; position arrow
                sta SP01_X_POS          ; Sprite-1 x-position

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
                bne _XIT                ; if not done end ISR

                sta STPCNT              ; end of steps
                inc ORDCNT              ; next order
                lda ORDCNT
                cmp HOWMNY              ; last order?
                bcc _XIT                ; no, out
                beq _XIT                ; no, out

                lda #$01
                sta ORDCNT              ; yes, reset to start of arrow's path

;   display maltese cross ('maltakreuze' or KRZ)
_printCursor    ldy STEPY
                sty KRZY
                lda #$FF
                sta KRZFLG
                ldx #$00
_next5          lda MLTKRZ,X
                cpy #$80
                bcs _16

                .setbank $05
                sta PLYR2,Y
                .setbank $03
_16             iny
                inx
                cpx #$08
                bne _next5

                lda STEPX
                sec
                sbc #$01
                sta KRZX
                sta SP02_X_POS          ; Sprite-2 x-position
                jsr ClearArrow

                lda BASEX               ; reset arrow's coords
                sta STEPX
                lda BASEY
                sta STEPY

_XIT             jmp ENDISR


;--------------------------------------
; Looks for a unit inside cursor
; If there is one, put unit info into
; text window
;--------------------------------------
FirstBtnPass    lda #$FF
                sta BUTFLG

;   first get coords of center of cursor (map frame)
                lda CURSXL
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
_next1          cmp CorpsY,X
                beq _1

_next2          dex
                bne _next1

                stx CORPS               ; no match obtained
                dex
                stx HITFLG
                jmp ENDISR

_1              lda CHUNKX
                cmp CorpsX,X
                bne _2

                lda ArrivalTurn,X
                bmi _2

                cmp TURN
                bcc _match
                beq _match

_2              lda CHUNKY
                jmp _next2

;   match obtained
_match          lda #$00
                sta HITFLG              ; note match
                sta KEYCHAR             ; last key pressed
                lda #$5C
                sta LUTSprColor0        ; TODO: Sprite-0 color - light up cursor

;   display unit specs
                stx CORPS
                ldy #$0D
                lda CorpNumber,X        ; ID number
                jsr DisplayNumber

                iny
                ldx CORPS
                lda CorpType,X          ; first name
                sta TEMPI
                and #$F0
                lsr A
                jsr DisplayWord.ENTRY2

                lda TEMPI
                and #$0F                ; second name
                clc
                adc #$08
                jsr DisplayWord

                lda #$1E
                ldx CORPS
                cpx #$37                ; when Russian
                bcs _3

                lda #$1D
_3              jsr DisplayWord         ; display unit size (corps or army)

                ldy #$38
                lda #$1F                ; "MUSTER"
                jsr DisplayWord

                dey

                .setbank $04
                lda #$1A                ; ":"
                sta TXTWDW,Y
                .setbank $03

                iny
                iny
                ldx CORPS
                lda MusterStrength,X    ; muster strength
                jsr DisplayNumber

                iny
                iny
                lda #$20                ; "COMBAT"
                jsr DisplayWord

                lda #$21                ; "STRENGTH"
                jsr DisplayWord

                dey

                .setbank $04
                lda #$1A                ; ":"
                sta TXTWDW,Y
                .setbank $03

                iny
                iny
                ldx CORPS
                lda CombatStrength,X    ; combat strength
                jsr DisplayNumber
                jsr SwitchCorps         ; flip unit with terrain

                lda CORPS
                cmp #$37
                bcc _4                  ; Russian?

                lda #$FF                ; yes, mask orders and exit
                sta HITFLG
                bmi _XIT

;
;German unit
;set up orders display
;first calculate starting coords (BASEX, BASEY)
;
_4              lda #$01
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
_XIT            jmp ENDISR


;--------------------------------------
; Orders input routine
;--------------------------------------
ORDERS          lda STKFLG
                bne FirstBtnPass._XIT

                ldx CORPS
                cpx #$37                ; when Russian
                bcc _1

                ldx #$00                ; yes, error
                jmp Squawk

_1              lda HowManyOrders,X
                cmp #$08
                bcc _2                  ; only 8 orders allowed

                ldx #$20
                jmp Squawk

_2             lda KRZFLG
                bne _3                  ; must wait for maltakreuze

                ldx #$40
                jmp Squawk

_3              inc DBTIMR
                lda DBTIMR              ; wait for debounce time
                cmp #$10
                bcs _4

                bcc FirstBtnPass._XIT

_4              lda #$00
                sta DBTIMR              ; reset debounce timer
                lda JOYSTICK0           ; joystick0 read
                and #$0F
                tax
                lda STKTAB,X
                bpl _5

                ldx #$60                ; no diagonal orders allowed
                jmp Squawk

;   OK, this is a good order
_5              tay
                sta STICKI
                lda BEEPTB,Y
                sta SID_FREQ1           ; TODO: "BEEP!"
                lda #$A8
                sta SID_CTRL1           ; TODO: distortion-5; half volume
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
_next1          dey
                bmi _6

                asl A
                asl A
                jmp _next1

_6              ldy TEMPI
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
                jsr ClearMaltakreuze

                ldx STICKI
                lda KRZX
                clc
                adc XOFF,X
                sta KRZX
                lda KRZY
                clc
                adc YOFF,X
                sta KRZY
                lda KRZX                ; display it
                sta SP02_X_POS          ; Sprite-2 x-position
                ldy KRZY
                ldx #$00

                .setbank $05

_next2          lda MLTKRZ,X
                cpy #$80
                bcs _7

                sta PLYR2,Y
_7              iny
                inx
                cpx #$08
                bne _next2

                .setbank $03

                beq EXITI


;--------------------------------------
; ERROR on inputs routine
; Squawks speaker and error message
;--------------------------------------
Squawk          ldy #$69

                .setbank $04
_next1          lda ERRMSG,X
                sec
                sbc #$20
                sta TXTWDW,Y
                iny
                inx
                txa
                and #$1F
                bne _next1

                .setbank $03

                lda #$68
                sta SID_CTRL1           ; TODO: distortion-3; half volume
                lda #$50
                sta SID_FREQ1           ; TODO: "HONK!"
                lda #$FF
                sta ERRFLG
                bmi EXITI


;--------------------------------------
; No button pressed routine
;--------------------------------------
NoButton        sta DBTIMR
                lda JOYSTICK0           ; joystick0 read
                and #$0F
                eor #$0F
                bne Scroll

                sta SID_CTRL1           ; TODO: no distortion; volume set based on joystick movement
                sta STKFLG
                lda #$08
                sta DELAY
                clc
                adc JIFFYCLOCK          ; TODO:
                sta TIMSCL
                jsr ERRCLR


;--------------------------------------
;
;--------------------------------------
EXITI           jmp ENDISR


;--------------------------------------
;
;--------------------------------------
;   acceleration feature of cursor
Scroll          lda TIMSCL
                cmp JIFFYCLOCK          ; TODO:
                bne EXITI

                lda DELAY
                cmp #$01
                beq _1

                sec
                sbc #$01
                sta DELAY
_1              clc
                adc JIFFYCLOCK          ; TODO:
                sta TIMSCL

                lda #$00
                sta OFFLO
                sta OFFHI               ; zero the offset

                lda JOYSTICK0           ; joystick0 read
                and #$0F
                pha                     ; save it on stack for other bit checks
                and #$08                ; joystick left?
                bne _checkRight         ; no, move on

                lda CURSXL
                bne _2

                ldx CURSXH
                beq _checkUp

_2              sec
                sbc #$01
                sta CURSXL
                bcs _3

                dec CURSXH
_3              lda SHPOS0
                cmp #$BA
                beq _4

                clc
                adc #$01
                sta SHPOS0
                sta SP00_X_POS          ; Sprite-0 x-position
                bne _checkUp

_4              .m16
                lda X_POS
                sec                     ; decrement x-coordinate
                sbc #$01
                sta X_POS
                sta TILE3_WINDOW_X_POS  ; fine scroll
                .m8
                bra _checkUp            ; no, move on

                ; inc OFFLO             ; yes, mark it for offset
                ; clv
                ; bvc _checkUp          ; no point in checking for joystick right

_checkRight     pla                     ; get back joystick byte
                pha                     ; save it again
                and #$04                ; joystick right?
                bne _checkUp            ; no, move on

                lda CURSXL
                cmp #$64
                bne _5

                ldx CURSXH
                bne _checkUp

_5              clc
                adc #$01
                sta CURSXL
                bcc _6

                inc CURSXH
_6              lda SHPOS0
                cmp #$36
                beq _7

                sec
                sbc #$01
                sta SHPOS0
                sta SP00_X_POS          ; Sprite-0 x-position
                bne _checkUp

_7              .m16
                lda X_POS
                clc                     ; no, increment x-coordinate
                adc #$01
                sta X_POS
                sta TILE3_WINDOW_X_POS  ; fine scroll
                .m8
                bra _checkUp            ; scroll overflow? if not, move on

                ;dec OFFLO              ; yes, set up offset for character scroll
                ;dec OFFHI
_checkUp        pla                     ; joystick up?
                lsr A
                pha
                bcs _checkDown          ; no, ramble on

                lda CURSYL
                cmp #$5E
                bne _8

                ldx CURSYH
                cpx #$02
                beq _checkDown

_8              inc CURSYL
                bne _9

                inc CURSYH
_9              ldx SCY
                cpx #$1B
                beq _11

                inc CURSYL
                bne _10

                inc CURSYH
_10             dex
                stx SCY
                txa
                clc
                adc #$12
                sta TEMPI
_next1          lda PLYR0,X             ; move cursor up one line
                sta PLYR0-1,X
                inx
                cpx TEMPI
                bne _next1
                beq _checkDown

_11             .m16
                lda Y_POS
                sec
                sbc #$01
                sta Y_POS
                sta TILE3_WINDOW_Y_POS  ; fine scroll
                .m8
                bra _checkDown          ; scroll overflow? If not, amble on

                lda OFFLO               ; yes, set up offset for character scroll
                sec
                sbc #$30
                sta OFFLO
                lda OFFHI
                sbc #$00
                sta OFFHI
_checkDown           pla                ; joystick down?
                lsr A
                bcs _changeDLIST        ; no, trudge on

                lda CURSYL
                cmp #$02
                bne _12

                ldx CURSYH
                beq _changeDLIST

_12             sec
                sbc #$01
                sta CURSYL
                bcs _13

                dec CURSYH
_13             ldx SCY
                cpx #$4E
                beq _15

                sec
                sbc #$01
                sta CURSYL
                bcs _14

                dec CURSYH
_14             inx
                stx SCY
                txa
                clc
                adc #$12
                dex
                dex
                stx TEMPI
                tax
_next2          lda PLYR0-1,X           ; move cursor down one line
                sta PLYR0,X
                dex
                cpx TEMPI
                bne _next2
                beq _changeDLIST

_15             .m16
                lda Y_POS
                clc                     ; no, decrement y-coordinate
                adc #$01
                sta Y_POS
                sta TILE3_WINDOW_Y_POS  ; fine scroll
                .m8
                bne _changeDLIST        ; no, move on

                lda OFFLO               ; yes, mark offset
                clc
                adc #$30
                sta OFFLO
                lda OFFHI
                adc #$00
                sta OFFHI

;
; In this loop we add the offset values to the existing
; LMS addresses of all display lines.
; This scrolls the characters.
;
_changeDLIST    ldy #$09
_next3          lda (DLSTPT),Y
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
                bne _next3


;--------------------------------------
;
;--------------------------------------
ENDISR          .proc
                .m16
                lda Y_POS
                lsr A
                lsr A
                lsr A
                lsr A
                lsr A
                .m8
                cmp #$11
                bcs _1

                lda #$FF
                bmi _3

_1              cmp #$1A
                bcc _2

                lda #$02
                bpl _3

_2              sta TEMPI
                inx
                lda #$1D
                sec
                sbc TEMPI
_3              sta CNT1
                lda #$00
                sta CNT2
                ;jmp XITVBV              ; exit vertical blank routine  ; TODO:platform

                .endproc


;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------


;======================================
; Display a single word from a long
; table of words
;======================================
DisplayWord     .proc
                asl A
                asl A
                asl A
                bcc ENTRY2

                .setbank $04
                tax
_next1          lda WordsTbl+256,X
                sec
                sbc #$20
                beq _1

                sta TXTWDW,Y
                iny
                inx
                txa
                and #$07
                bne _next1

                .setbank $03

_1              iny
                rts

ENTRY2          tax                     ; this is another entry point

                .setbank $04

_next1          lda WordsTbl,X
                sec
                sbc #$20
                beq _1

                sta TXTWDW,Y
                iny
                inx
                txa
                and #$07
                bne _next1

                .setbank $03

_1              iny
                rts
                .endproc


;======================================
; Swap corps with terrain
;======================================
SwitchCorps     .proc
                lda #$00
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
                beq _XIT

                pha
                lda SWAP,X
                sta (MAPLO),Y
                pla
                sta SWAP,X
_XIT            rts
                .endproc


;======================================
; Clear the arrow player
;======================================
ClearArrow      .proc
                lda #$00
                ldy STEPY
                dey
                tax

                .setbank $05

_next1          cpy #$80
                bcs _1

                sta PLYR1,Y
_1              iny
                inx
                cpx #$0B
                bne _next1

                .setbank $03

                rts
                .endproc


;======================================
; Clear the Maltakreuze
;======================================
ClearMaltakreuze .proc
                lda #$00
                ldy KRZY
                tax

                .setbank $05
_next1          cpy #$80
                bcs _1

                sta PLYR2,Y
_1              iny
                inx
                cpx #$0A
                bne _next1

                .setbank $03

                rts
                .endproc


;======================================
; Clear sound and the text window
;======================================
ERRCLR          .proc
                lda ERRFLG
                bpl _XIT

                lda #$00
                sta ERRFLG
                ldy #$86
                ldx #$1F

                .setbank $04

_next1          sta TXTWDW,Y
                dey
                dex
                bpl _next1

                .setbank $03

_XIT            rts
                .endproc


;
;From here to $7B00 is expansion RAM
;

;
;This is the DLI routine
;

;--------------------------------------
;--------------------------------------
                .align $1000
;--------------------------------------


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DLISRV          pha
                txa
                pha
                inc CNT2
                lda CNT2
                cmp CNT1
                bne _1

                ldx #$62                ; map DLI
                lda #$28
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                ;sta WSYNC              ; TODO:platform
                ;stx CHBASE             ; TODO: convert to tiles     ; charset = $6200
                sta LUTPfColor0         ; TODO: playfield-0 color
                jmp _XIT

_1              cmp #$0F
                bne _2

                lda #$3A
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                tax
                lda #$00
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                ;sta WSYNC              ; TODO:platform
                ;stx LUTPfColor2        ; TODO: playfield-2 color
                ;sta LUTPfColor1        ; TODO: playfield-1 color
                jmp _XIT

_2              cmp #$01
                bne _3

                lda TRCOLR              ; green tree color
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                tax
                lda #$1A                ; yellow band at top of map
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                ;sta WSYNC              ; TODO:platform
                ;sta LUTBkColor         ; TODO: background color
                ;stx LUTPfColor0        ; TODO: playfield-0 color

                ;lda #$60
                ;sta CHBASE             ; TODO: convert to tiles     ; charset = $6000

                jmp _XIT

_3              cmp #$03
                bne _4

                lda EARTH               ; top of map
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                ;sta WSYNC              ; TODO:platform
                sta LUTBkColor          ; TODO: background color
                jmp _XIT

_4              cmp #$0D
                bne _5

                ;ldx #$E0               ; bottom of map
                lda #$22
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                ;sta WSYNC              ; TODO:platform
                sta LUTPfColor2         ; TODO: playfield-2 color
                ;stx CHBASE             ; TODO: convert to tiles     ; charset = standard OS charset
                jmp _XIT

_5              cmp #$0E
                bne _6

                lda #$8A                ; bright blue strip
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                ;sta WSYNC              ; TODO:platform
                sta LUTBkColor          ; TODO: background color
                jmp _XIT

_6              cmp #$10
                bne _XIT

                lda #$D4                ; green bottom
                ;eor COLRSH             ; TODO:platform
                ;and DRKMSK             ; TODO:platform
                pha                     ; some extra delay
                pla
                nop
                sta LUTBkColor          ; TODO: background color

_XIT            pla
                tax
                pla
                rti


;======================================
; Display a number with leading-zero
; suppressed
;======================================
DisplayNumber   .proc
                .setbank $04

                tax
                clc
                lda HundredDigit,X
                beq _1

                adc #$10
                sta TXTWDW,Y
                iny
                sec
_1              lda TensDigit,X
                bcs _2
                beq _3

_2              clc
                adc #$10
                sta TXTWDW,Y
                iny
_3              lda OnesDigit,X
                clc
                adc #$10
                sta TXTWDW,Y
                iny

                .setbank $03

                rts
                .endproc

