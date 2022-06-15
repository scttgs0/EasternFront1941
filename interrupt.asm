;===================================================================
;===================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;===================================================================


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; To be relocated to 00:2000
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HandleIrq       jml DVBI
                ;jmp IRQ_PRIOR


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Deferred vertical blank interrupt
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DVBI            .proc
                .m8i8
                .setbank $03

                lda JIFFYCLOCK
                inc A
                sta JIFFYCLOCK

;--------------------------------------

;   debug entry
                ;lda JOYSTICK1          ; read joystick1 button (check for break button)
                ;and #$10
                lda #$FF                ; force break to be ignored
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
;   end debug mode

;--------------------------------------

_1              lda HANDICAP
                beq _3                  ; skip when handicap is active

                lda JOYSTICK0           ; read joystick0 button
                ;lda #$1F    ; HACK:
                and #$10
                beq _3                  ; skip when button is pressed

                lda #$07
                sta CONSOL              ; TODO: reset function keys
                lda CONSOL              ; TODO: read function keys
                and #$04                ; OPTION key
                bne _3

                sta HANDICAP            ; enable Handicap when OPTION is pressed

                ldx #$36
_next1          lda MusterStrength,X    ; muster strength = 150%... 255 max
                sta TEMPI
                lsr A
                adc TEMPI
                bcc _2

                lda #$FF
_2              sta MusterStrength,X
                dex
                bne _next1

_3              lda JOYSTICK0           ; read joystick0 button
                ;lda #$1F    ; HACK:
                and #$10
                ora BUTTON_MASK         ; button allowed?
                beq _5

                lda BUTTON_FLAG         ; no button now; previous status
                bne _4

                jmp NoButton

_4              lda #$58                ; button just released
                sta LUTSprColor0        ; TODO: Sprite-0 color

                lda #$00
                sta BUTTON_FLAG         ; =false
                sta KRZFLG
                sta SID_CTRL1           ; TODO: no distortion; no volume

                ldx #79
_next2          sta TXTWDW,X            ; clear text window
                dex
                bpl _next2

                lda #$08
                sta DELAY
                clc
                adc JIFFYCLOCK
                sta scrollTimer

                jsr SwitchCorps

                lda #$00
                sta activeCorps
                jsr ClearArrow
                jsr ClearMaltakreuze

                jmp ENDISR

_5              lda JOYSTICK0           ; button is pressed - joystick0 read
                ;lda #$1F    ; HACK:
                and #$0F
                eor #$0F
                beq _6                  ; joystick deflection?

                jmp ORDERS              ;   yes

_6              sta DEBOUNCE_TIMER      ;   no, clear debounce
                sta SID_CTRL1           ; TODO: distortion/volume
                sta JoystickFlag

                lda BUTTON_FLAG
                bne _7                  ; is this the first button pass

                jmp FirstBtnPass        ; yes

_7              jsr ClearError          ; no, clear errors

                lda HITFLG
                beq _8                  ; anybody in the window?

                jmp ENDISR              ; no

_8              lda KEYCHAR             ; last key pressed
                cmp #$21
                bne _9                  ; space bar pressed?

                ldx activeCorps         ;   yes, check for Russian
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
_9              lda JIFFYCLOCK
                and #$03
                beq _10                 ; time to move arrow?

                jmp ENDISR              ;   no

_10             ldy HOWMNY              ;   yes
                bne _11                 ; any orders to show?

                jmp _printCursor        ;   no, go ahead to maltakreuze

_11             jsr ClearArrow          ;   yes, clear old arrow

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
                bcc _XIT                ;   no, out
                beq _XIT                ;   no, out

                lda #$01
                sta ORDCNT              ;   yes, reset to start of arrow's path

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

_XIT            jmp ENDISR

                .endproc


;--------------------------------------
; Looks for a unit inside cursor
; If there is one, put unit info into
; text window
;--------------------------------------
FirstBtnPass    .proc
                lda #$FF
                sta BUTTON_FLAG         ; =true

;   first get coords of center of cursor (map frame)
                .m16
                lda cursorMapX
                clc
                adc #$10
                sta TXL                 ; 16-bit intentional

                lda cursorMapY
                clc
                adc #$10
                sta TYL                 ; 16-bit intentional

;   coords of cursor (pixel frame)
;   activeCorpsX = /16
;   activeCorpsY = /16
                .m8
                lda TXH
                lsr A                   ; /8
                lda TXL
                ror A
                lsr A
                lsr A
                sta activeCorpsX

                lda TYH
                lsr A                   ; /2
                tax                     ; save in X

                lda TYL                 ; continue /2
                ror A
                tay                     ; save in Y

                txa                     ; restore high-byte
                lsr A                   ; /2

                tya                     ; restore low-byte
                ror A                   ; continue /2
                lsr A                   ; /2
                lsr A                   ; /2
                sta activeCorpsY

;   look for a match with unit coordinates
                ldx #$9E
_next1          cmp CorpsY,X
                beq _1

_next2          dex
                bne _next1

                stx activeCorps         ; no match obtained
                dex
                stx HITFLG
                jmp ENDISR

_1              lda activeCorpsX
                cmp CorpsX,X
                bne _2

                lda ArrivalTurn,X
                bmi _2

                cmp TURN
                bcc _match
                beq _match

_2              lda activeCorpsY
                jmp _next2

;   match obtained
_match          lda #$00
                sta HITFLG              ; note match
                sta KEYCHAR             ; last key pressed
                lda #$5C
                sta LUTSprColor0        ; TODO: Sprite-0 color - light up cursor

;   display unit specs
                stx activeCorps
                ldy #$0D
                lda CorpNumber,X        ; ID number
                jsr DisplayNumber

                iny
                ldx activeCorps
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
                ldx activeCorps
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
                ldx activeCorps
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
                lda #$3A                ; ":"
                sta TXTWDW,Y
                .setbank $03

                iny
                iny
                ldx activeCorps
                lda CombatStrength,X    ; combat strength
                jsr DisplayNumber
                jsr SwitchCorps         ; flip unit with terrain

                lda activeCorps
                cmp #$37
                bcc _4                  ; Russian?

                lda #$FF                ; yes, mask orders and exit
                sta HITFLG
                bra _XIT

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
                adc shSpr0PositionX     ; TODO: 16-bit
                sta BASEX
                sta STEPX

                lda TYL
                and #$0F
                lsr A
                sec
                sbc #$01
                clc
                adc shSpr0PositionY     ; TODO: 16-bit'
                sta BASEY
                sta STEPY

;   set up page 6 values
                ldx activeCorps
                lda HowManyOrders,X
                sta HOWMNY
                lda WhatOrders,X
                sta ORD1
                lda WHORDH,X
                sta ORD2
_XIT            jmp ENDISR

                .endproc


;--------------------------------------
; Orders input routine
;--------------------------------------
ORDERS          .proc
                lda JoystickFlag
                bne FirstBtnPass._XIT

                ldx activeCorps
                cpx #$37                ; when Russian
                bcc _1

                ldx #$00                ; yes, error
                jmp Squawk

_1              lda HowManyOrders,X
                cmp #$08
                bcc _2                  ; only 8 orders allowed

                ldx #$20
                jmp Squawk

_2              lda KRZFLG
                bne _3                  ; must wait for maltakreuze

                ldx #$40
                jmp Squawk

_3              inc DEBOUNCE_TIMER
                lda DEBOUNCE_TIMER      ; wait for debounce time
                cmp #$10
                bcs _4

                bcc FirstBtnPass._XIT

_4              lda #$00
                sta DEBOUNCE_TIMER      ; reset debounce timer
                lda JOYSTICK0           ; joystick0 read
                ;lda #$1F    ; HACK:
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
                sta JoystickFlag

                ldx activeCorps
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
                ldx activeCorps
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

                bra EXITI

                .endproc


;--------------------------------------
; No button pressed routine
;--------------------------------------
NoButton        .proc
                sta DEBOUNCE_TIMER

                lda JOYSTICK0           ; joystick0 read
                ;lda #$1F    ; HACK:
                and #$0F
                eor #$0F
                bne Scroll

                sta SID_CTRL1           ; TODO: no distortion; volume set based on joystick movement
                sta JoystickFlag

                lda #$08
                sta DELAY
                clc
                adc JIFFYCLOCK
                sta scrollTimer

                jsr ClearError

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
EXITI           jmp ENDISR


;--------------------------------------
;
;--------------------------------------
;   acceleration feature of cursor
Scroll          .proc
                lda scrollTimer
                cmp JIFFYCLOCK
                bne EXITI

                sei

                lda DELAY
                cmp #$01
                beq _1

                dec A
                sta DELAY

_1              clc
                adc JIFFYCLOCK
                sta scrollTimer

                lda #$00
                sta OFFLO
                sta OFFHI               ; zero the offset

                lda JOYSTICK0           ; joystick0 read
                ;lda #$1F    ; HACK:
                and #$0F
                pha                     ; save it on stack for other bit checks

_checkLeft      .m8
                pla
                pha
                and #$04                ; joystick left?
                bne _checkRight         ;   no, move on

                .m16
                lda cursorMapX          ; already at limit?
                cmp #$28
                beq _checkUp            ;   yes, move on

_2              dec A
                dec A
                sta cursorMapX

_3              lda shSpr0PositionX
                cmp #$28
                beq _4

                dec A
                dec A
                sta shSpr0PositionX
                sta SP00_X_POS          ; Sprite-0 x-position
                bne _checkUp

_4              lda X_POS
                beq _checkUp

                dec A                   ; decrement x-coordinate
                dec A
                sta X_POS
                sta TILE3_WINDOW_X_POS  ; fine scroll
                sta TILE2_WINDOW_X_POS

                bra _checkUp            ; no, move on

                ; inc OFFLO             ; yes, mark it for offset
                ; clv
                ; bvc _checkUp          ; no point in checking for joystick right

_checkRight     .m8
                pla                     ; get back joystick byte
                pha                     ; save it again
                and #$08                ; joystick right?
                bne _checkUp            ;   no, move on

                .m16
                lda cursorMapX
                cmp #$2F8
                beq _checkUp

_5              inc A
                inc A
                sta cursorMapX

_6              lda shSpr0PositionX
                cmp #$278
                beq _7

                inc A
                inc A
                sta shSpr0PositionX
                sta SP00_X_POS          ; Sprite-0 x-position
                bne _checkUp

_7              lda X_POS
                cmp #$80
                beq _checkUp

                inc A                   ; no, increment x-coordinate
                inc A
                sta X_POS
                sta TILE3_WINDOW_X_POS  ; fine scroll
                sta TILE2_WINDOW_X_POS

                bra _checkUp            ; scroll overflow? if not, move on

                ;dec OFFLO              ; yes, set up offset for character scroll
                ;dec OFFHI

_checkUp        .m8
                pla                     ; get back joystick byte
                pha                     ; save it again
                and #$01                ; joystick up?
                bne _checkDown          ;   no, ramble on

                pla                     ; clean up stack

                .m16
                lda cursorMapY
                cmp #$48
                beq _checkDown

_8              dec A
                dec A
                sta cursorMapY

_9              lda shSpr0PositionY
                cmp #$48
                beq _11

_10             dec A
                dec A
                sta shSpr0PositionY
                sta SP00_Y_POS
                bra _XIT

_11             lda Y_POS
                beq _XIT

                dec A
                dec A
                sta Y_POS
                sta TILE3_WINDOW_Y_POS  ; fine scroll
                sta TILE2_WINDOW_Y_POS
                bra _XIT

_11skip         ;bra _checkDown          ; scroll overflow? If not, amble on

                ; lda OFFLO               ; yes, set up offset for character scroll
                ; sec
                ; sbc #$30
                ; sta OFFLO
                ; lda OFFHI
                ; sbc #$00
                ; sta OFFHI

_checkDown      .m8
                pla
                and #$02                ; joystick down?
                bne _XIT                ;   no, trudge on

                .m16
                lda cursorMapY
                cmp #$2A8
                beq _XIT

_12             inc A
                inc A
                sta cursorMapY

_13             lda shSpr0PositionY
                cmp #$188
                beq _15

_14             inc A
                inc A
                sta shSpr0PositionY
                sta SP00_Y_POS
                bra _XIT

_15             lda Y_POS
                cmp #$120
                beq _XIT

                inc A                   ; no, decrement y-coordinate
                inc A
                sta Y_POS
                sta TILE3_WINDOW_Y_POS  ; fine scroll
                sta TILE2_WINDOW_Y_POS
                bra _XIT                ; no, move on

                ; .m8
                ; lda OFFLO               ; yes, mark offset
                ; clc
                ; adc #$30
                ; sta OFFLO
                ; lda OFFHI
                ; adc #$00
                ; sta OFFHI

_XIT            .m8
                cli
                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
ENDISR          .proc
                .m16
                lda Y_POS
                lsr A                   ; /32
                lsr A
                lsr A
                lsr A
                lsr A

                .m8
                cmp #$11
                bcs _1

                lda #$FF
                bra _3

_1              cmp #$1A
                bcc _2

                lda #$02
                bra _3

_2              sta TEMPI
                inx
                lda #$1D
                sec
                sbc TEMPI

_3              rti
                .endproc


;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------


;======================================
; Swap corps with terrain
;======================================
SwitchCorps     .proc
                php
                .setbank $04
                .m16i8

;   MAP origin is lower-right
;   TEMPLO origin is upper-left
;   conver the coordinate systems
;   TEMPLO = 38-activeCorpsY*49
                lda #38                 ; MAP HEIGHT excluding border
                .m8
                sec
                sbc activeCorpsY
                .m16
;   multiple by 49 -- *32 + *16 + *1 = *49
                pha
                asl A                   ; *32
                asl A
                asl A
                asl A
                asl A
                sta TEMPLO
                pla
                pha
                asl A                   ; *16
                asl A
                asl A
                asl A
                clc
                adc TEMPLO
                sta TEMPLO
                pla                     ; *1
                clc
                adc TEMPLO

                clc
                adc #$E000+MAPWIDTH*3   ; MAP address + top border
                sta pMap

;   offset = 45-activeCorpsX+2
                lda #45                 ; MAP WIDTH excluding border
                .m8
                sec
                sbc activeCorpsX
                .m16
                clc
                adc #2

;   retrieve the terrain type
                .m8
                tay
                lda (pMap),Y

                ldx activeCorps         ; index 0 is unused -- indicates the end of the list
                beq _XIT

                pha
                lda SWAP,X
                sta (pMap),Y
                pla
                sta SWAP,X

;   place unit tile
                .m16
                lda pMap
                clc
                adc #$1000              ; UNIT tile map is $1000 bytes ahead of MAP
                sta TEMPLO

                .m8
                lda (pMap),Y
                cmp #$3D                ; german
                beq _1
                cmp #$3E
                beq _1
                cmp #$7D                ; russian
                beq _1
                cmp #$7E
                beq _1
                cmp #$80                ; axis minor
                beq _1
                cmp #$81
                beq _1
                cmp #$82
                beq _1

                lda #$00                ; not a unit counter -- clear the tile
                sta (TEMPLO),Y
                bra _XIT

_1              sta (TEMPLO),Y          ; place the unit on the UNIT tile map

_XIT            .setbank $03
                plp
                rts
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


;--------------------------------------
; ERROR on inputs routine
; Squawks speaker and error message
;--------------------------------------
Squawk          .proc
                ldy #$00

                .setbank $04
_next1          lda ERRMSG,X
                sta FooterText3+4,Y
                iny
                inx
                cpy #$20
                bne _next1

                .setbank $03
                lda #$68
                sta SID_CTRL1           ; TODO: distortion-3; half volume
                lda #$50
                sta SID_FREQ1           ; TODO: "HONK!"
                lda #$FF
                sta ERRFLG
                jmp EXITI

                .endproc


;======================================
; Clear sound and the text window
;======================================
ClearError      .proc
                lda ERRFLG
                bpl _XIT

                lda #$00
                sta ERRFLG

                .setbank $04
                ldy #$00
                ldx #$1F
_next1          sta FooterText3+4,Y
                dey
                dex
                bpl _next1

                .setbank $03
_XIT            rts
                .endproc


;======================================
; Display a number with leading-zero
; suppressed
;--------------------------------------
; at entry
;   A           Value
;   Y           Position offset
;======================================
DisplayNumber   .proc
                .setbank $04

                tax
                clc
                lda HundredDigit,X
                beq _1

                adc #$30
                sta TXTWDW,Y
                iny
                sec
_1              lda TensDigit,X
                bcs _2
                beq _3

_2              clc
                adc #$30
                sta TXTWDW,Y
                iny
_3              lda OnesDigit,X
                clc
                adc #$30
                sta TXTWDW,Y
                iny

                .setbank $03
                rts
                .endproc


;======================================
; Display a single word from a long
; table of words
;======================================
DisplayWord     .proc
                asl A                   ; *8
                asl A
                asl A
                bcc ENTRY2

                .setbank $04
                tax
_next1          lda WordsTbl+256,X      ; COMBAT|STRENGTH
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
                cmp #$20                ; finished once we hit the first space character
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
