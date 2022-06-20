;===================================================================
;===================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;===================================================================


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; To be relocated to 00:2000
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                .logical $00_2000

HandleIrq       .m16i16
                pha
                phx
                phy

                .m8i8
                lda @l INT_PENDING_REG1
                and #FNX1_INT00_KBD
                cmp #FNX1_INT00_KBD
                bne _1

                jsl KeyboardHandler

                lda @l INT_PENDING_REG1
                sta @l INT_PENDING_REG1

_1              lda @l INT_PENDING_REG0
                and #FNX0_INT00_SOF
                cmp #FNX0_INT00_SOF
                bne _XIT

                jsl VbiHandler

                lda @l INT_PENDING_REG0
                sta @l INT_PENDING_REG0

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
HandleIrq_END   rti
                ;jmp IRQ_PRIOR

                .endlogical


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Handle Key notifications
;--------------------------------------
;   ESC         $01/$81  press/release
;   R-Ctrl      $1D/$9D
;   Space       $39/$B9
;   F2          $3C/$BC
;   F3          $3D/$BD
;   F4          $3E/$BE
;   Up          $48/$C8
;   Left        $4B/$CB
;   Right       $4D/$CD
;   Down        $50/$D0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
KeyboardHandler .proc
KEY_F2          = $3C                   ; Option
KEY_F3          = $3D                   ; Select
KEY_F4          = $3E                   ; Start
KEY_UP          = $48                   ; joystick alternative
KEY_LEFT        = $4B
KEY_RIGHT       = $4D
KEY_DOWN        = $50
KEY_CTRL        = $1D                   ; fire button
;---

                .m16i16
                pha
                phx
                phy

                .m8i8
                .setbank $03

                lda KBD_INPT_BUF
                pha
                sta KEYCHAR

                and #$80                ; is it a key release?
                bne _1r                 ;   yes

_1              pla                     ;   no
                pha
                cmp #KEY_F2
                bne _2

                lda CONSOL
                eor #$04
                sta CONSOL

                jmp _CleanUpXIT

_1r             pla
                pha
                cmp #KEY_F2|$80
                bne _2r

                lda CONSOL
                ora #$04
                sta CONSOL

                jmp _CleanUpXIT

_2              pla
                pha
                cmp #KEY_F3
                bne _3

                lda CONSOL
                eor #$02
                sta CONSOL

                jmp _CleanUpXIT

_2r             pla
                pha
                cmp #KEY_F3|$80
                bne _3r

                lda CONSOL
                ora #$02
                sta CONSOL

                jmp _CleanUpXIT

_3              pla
                pha
                cmp #KEY_F4
                bne _4

                lda CONSOL
                eor #$01
                sta CONSOL

                jmp _CleanUpXIT

_3r             pla
                pha
                cmp #KEY_F4|$80
                bne _4r

                lda CONSOL
                ora #$01
                sta CONSOL

                jmp _CleanUpXIT

_4              pla
                pha
                cmp #KEY_UP
                bne _5

                lda InputFlags
                eor #$01
                ora #$02                ; cancel KEY_DOWN
                sta InputFlags

                lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_4r             pla
                pha
                cmp #KEY_UP|$80
                bne _5r

                lda InputFlags
                ora #$01
                sta InputFlags

                jmp _CleanUpXIT

_5              pla
                pha
                cmp #KEY_DOWN
                bne _6

                lda InputFlags
                eor #$02
                ora #$01                ; cancel KEY_UP
                sta InputFlags

                lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_5r             pla
                pha
                cmp #KEY_DOWN|$80
                bne _6r

                lda InputFlags
                ora #$02
                sta InputFlags

                jmp _CleanUpXIT

_6              pla
                pha
                cmp #KEY_LEFT
                bne _7

                lda InputFlags
                eor #$04
                ora #$08                ; cancel KEY_RIGHT
                sta InputFlags

                lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_6r             pla
                pha
                cmp #KEY_LEFT|$80
                bne _7r

                lda InputFlags
                ora #$04
                sta InputFlags

                bra _CleanUpXIT

_7              pla
                pha
                cmp #KEY_RIGHT
                bne _8

                lda InputFlags
                eor #$08
                ora #$04                ; cancel KEY_LEFT
                sta InputFlags

                lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_7r             pla
                pha
                cmp #KEY_RIGHT|$80
                bne _8r

                lda InputFlags
                ora #$08
                sta InputFlags

                bra _CleanUpXIT

_8              pla
                cmp #KEY_CTRL
                bne _XIT

                lda InputFlags
                eor #$10
                sta InputFlags

                lda #itKeyboard
                sta InputType

                stz KEYCHAR
                bra _XIT

_8r             pla
                cmp #KEY_CTRL|$80
                bne _XIT

                lda InputFlags
                ora #$10
                sta InputFlags

                stz KEYCHAR
                bra _XIT

_CleanUpXIT     ;stz KEYCHAR    HACK:
                pla

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
                rtl
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Handle Vertical Blank Interrupt (SOF)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VbiHandler      .proc
                .m16i16
                pha
                phx
                phy

                .m8i8
                .setbank $03

                lda JIFFYCLOCK
                inc A
                sta JIFFYCLOCK

                lda JOYSTICK0           ; read joystick0
                and #$1F
                cmp #$1F
                beq _0                  ; when no activity, keyboard is alternative

                sta InputFlags          ; joystick activity -- override keyboard input
                lda #itJoystick
                sta InputType
                bra _1

_0              ldx InputType
                bne _1                  ; keyboard, move on

                sta InputFlags

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

                lda InputFlags          ; read fire button
                and #$10
                beq _3                  ; skip when button is pressed

                lda CONSOL              ; read function keys
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

_3              lda InputFlags          ; read fire button
                and #$10
                ora BUTTON_MASK         ; button allowed?
                bne _3a
                jmp _5

_3a             lda BUTTON_FLAG         ; no button now; previous status
                bne _4

                jmp NoButton

_4              .setbank $04            ; button just released
                lda SprColor0
                cmp #$84                ; is the cursor highlighted?
                beq _4a                 ;   no, skip

;   cursor is highlighted, so restore to normal
                ldy #2                  ;   yes, restore it
_nextChannel    lda SprColor0,Y         ; remove brightening on the cursor
                sec
                sbc #$30
                sta SprColor0,Y
                dey
                bpl _nextChannel

                jsr InitLUT

_4a             .setbank $03
                lda #$00
                sta BUTTON_FLAG         ; =false
                sta CrossFlag
                sta SID_CTRL1           ; TODO: no distortion; no volume

                .setbank $04
                ldx #79
_next2          sta TXTWDW,X            ; clear text window
                dex
                cpx #4
                bne _next2

                .RenderText $7A,$72,FooterText1,BITMAPTXT0
                .RenderText $7A,$72,FooterText2,BITMAPTXT1
                .m8i8

                .setbank $03
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

_5              lda InputFlags          ; button is pressed - joystick0 read
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

                lda HitFlag
                beq _8                  ; anybody in the window?

                jmp ENDISR              ;   no

_8              lda KEYCHAR             ; last key pressed
                cmp #$39                ; space bar pressed?
                bne _9                  ;   no, skip

                ldx activeCorps         ;   yes, check for Russian
                cpx #idxRussianUnits
                bcs _9

                lda #$00
                sta HowManyOrders,X     ; clear out orders
                sta HOWMNY
                sta StepCount

                lda #$01
                sta OrderCount
                jsr ClearArrow
                jsr ClearMaltakreuze

                .m16
                lda BASEX
                sta STEPX
                lda BASEY
                sta STEPY
                .m8

_9              lda JIFFYCLOCK
                and #$03
                beq _10                 ; time to move arrow?

                jmp ENDISR              ;   no

_10             ldy HOWMNY              ;   yes
                bne _11                 ; any orders to show?

                jmp _printCursor        ;   no, go ahead to maltakreuze

_11             jsr ClearArrow          ;   yes, clear old arrow

                lda OrderCount
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

_next3          lsr A                   ; /4
                lsr A
                dey
                bne _next3

;---
                .m16i16
_14             sta ArrowIndex
;   multiple by 1024 (size of the arrow stamp)
                xba                     ; *256
                and #$FF00
                asl A                   ; *4
                asl A
                sta wTEMP

;   get arrow image and store it to player RAM
                tax

                lda #<>(SPRITES+$800-VRAM)  ; PLYR1_UP is the base address
                clc
                adc wTEMP               ; add the displacement for the appropriate arrow
                sta SP01_ADDR

;                 .setbank $05
;                 ldy #$00
; _14a            lda PLYR1_UP,X
;                 sta PLYR1,Y
;                 inx
;                 inx
;                 iny
;                 iny
;                 cpy #$0400
;                 bne _14a

;                 .setbank $03

                lda STEPX               ; position arrow
                sta SP01_X_POS
                lda STEPY
                sta SP01_Y_POS

                .m16i8
;   now step arrow
                ldx ArrowIndex
                lda STEPX
                clc
                adc XADD,X
                sta STEPX
                lda STEPY
                clc
                adc YADD,X
                sta STEPY

                .m8
                inc StepCount           ; next step
                lda StepCount
                and #$07
                bne _XIT                ; if not done end ISR

                sta StepCount           ; end of steps
                inc OrderCount          ; next order
                lda OrderCount
                cmp HOWMNY              ; last order?
                bcc _XIT                ;   no, out
                beq _XIT                ;   no, out

                lda #$01
                sta OrderCount          ;   yes, reset to start of arrow's path

;   display maltese cross ('maltakreuze' or KRZ)
_printCursor    .m16
                lda STEPY
                and #$F0
                ora #$08
                sta CrossY
                sta SP02_Y_POS

                lda STEPX
                and #$F0
                ora #$08
                sta CrossX
                sta SP02_X_POS          ; Sprite-2 x-position

                .m8
                lda #$FF                ; cross is visible
                sta CrossFlag

                jsr ClearArrow

                .m16
                lda BASEX               ; reset arrow's coords
                sta STEPX
                lda BASEY
                sta STEPY
                .m8

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
                sec
                sbc #$10
                sta wTX

                lda cursorMapY
                sec
                sbc #$10
                sta wTY

;   coords of cursor (map frame)
;   activeCorpsX = /16
;   activeCorpsY = /16
                lda wTX
                lsr A                   ; /16
                lsr A
                lsr A
                lsr A
                sta activeCorpsX

                lda wTY
                lsr A                   ; /16
                lsr A
                lsr A
                lsr A
                sta activeCorpsY

;   look for a match with unit coordinates
                .m8
                ldx #corpsCount
_next1          lda CorpsY,X
                cmp activeCorpsY
                beq _1

_next2          dex
                bne _next1

                stx activeCorps         ; 0= no match obtained
                dex
                stx HitFlag             ; -1= no hit
                jmp ENDISR

_1              lda CorpsX,X
                cmp activeCorpsX
                bne _next2

                lda ArrivalTurn,X
                bmi _2

                cmp TURN                ; confirm unit is on the board
                bcc _match
                beq _match

_2              bra _next2

;   match obtained
_match          lda #$00
                sta HitFlag             ; note match

                stx activeCorps

                .setbank $04
                ldy #2                  ; brighten up the cursor
_nextChannel    lda SprColor0,Y
                clc
                adc #$30
                sta SprColor0,Y
                dey
                bpl _nextChannel

                jsr InitLUT

;   clear text window
                lda #$00
                ldy #$06                ; retain score
_nextChar       sta TXTWDW,Y
                iny
                cpy #80                 ; clear two lines
                bne _nextChar

;   display unit specs
                .setbank $03

                ldy #$08
                ldx activeCorps
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
                cpx #idxRussianUnits
                bcs _3

                lda #$1D
_3              jsr DisplayWord         ; display unit size (corps or army)

                ldy #$2B
                lda #$1F                ; "MUSTER"
                jsr DisplayWord

                .setbank $04
                dey
                lda #$3A                ; ":"
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

                .setbank $04
                dey
                lda #$3A                ; ":"
                sta TXTWDW,Y
                .setbank $03

                iny
                iny
                ldx activeCorps
                lda CombatStrength,X    ; combat strength
                jsr DisplayNumber

                .RenderText $7A,$72,FooterText1,BITMAPTXT0
                .RenderText $7A,$72,FooterText2,BITMAPTXT1
                .m8i8

                jsr SwitchCorps         ; flip unit with terrain

                lda activeCorps
                cmp #idxRussianUnits
                bcc _4                  ; Russian?

                lda #$FF                ; yes, mask orders and exit
                sta HitFlag
                bra _XIT

;
;German unit
;set up orders display
;first calculate starting coords (BASEX, BASEY)
;
_4              lda #$01
                sta OrderCount
                lda #$00
                sta StepCount

                .m16
                lda wTX
                and #$07
                clc
                adc #$01
                clc
                adc shSpr0PositionX
                sta BASEX
                sta STEPX

                lda wTY
                and #$0F
                lsr A
                sec
                sbc #$01
                clc
                adc shSpr0PositionY
                sta BASEY
                sta STEPY

;   set up page 6 values
                .m8
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
                cpx #idxRussianUnits
                bcc _1

                ldx #$00                ; yes, error
                jmp Squawk

_1              lda HowManyOrders,X
                cmp #$08
                bcc _2                  ; only 8 orders allowed

                ldx #$20
                jmp Squawk

_2              lda CrossFlag
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
                lda InputFlags          ; joystick0 read
                and #$0F
                tax
                lda JOYSTICK_TBL,X
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

                .m16
                ldx STICKI
                lda CrossX
                clc
                adc XOFF,X
                sta CrossX

                lda CrossY
                clc
                adc YOFF,X
                sta CrossY

                lda CrossX              ; display it
                sta SP02_X_POS          ; Sprite-2 x-position

                lda CrossY
                sta SP02_Y_POS
                .m8

                bra EXITI

                .endproc


;--------------------------------------
; No button pressed routine
;--------------------------------------
NoButton        .proc
                sta DEBOUNCE_TIMER

                lda InputFlags          ; joystick0 read
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

                lda InputFlags          ; joystick0 read
                and #$0F
                pha                     ; save it on stack for other bit checks

_checkLeft      .m8
                pla
                pha
                and #$04                ; joystick left?
                bne _checkRight         ;   no, move on

                .m16
                lda cursorMapX          ; already at limit?
                cmp #$2E8
                beq _checkUp            ;   yes, move on

_2              inc A
                inc A
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
                cmp #$18
                beq _checkUp

_5              dec A
                dec A
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
                cmp #$278
                beq _XIT

_8              inc A
                inc A
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
                cmp #$18
                beq _XIT

_12             dec A
                dec A
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

_3              .m16i16
                ply
                plx
                pla

                .m8i8
                rtl
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
;   wTEMP origin is upper-left
;   convert the coordinate systems
;   wTEMP = 38-activeCorpsY*50
                lda #38                 ; MAP HEIGHT excluding border
                .m8
                sec
                sbc activeCorpsY
                .m16
;   multiple by 50 -- *32 + *16 + *2 = *50
                pha
                asl A                   ; *32
                asl A
                asl A
                asl A
                asl A
                sta wTEMP
                pla
                pha
                asl A                   ; *16
                asl A
                asl A
                asl A
                clc
                adc wTEMP
                sta wTEMP
                pla
                asl A                   ; *2
                clc
                adc wTEMP

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
                sta wTEMP

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
                sta (wTEMP),Y
                bra _XIT

_1              sta (wTEMP),Y           ; place the unit on the UNIT tile map

_XIT            .setbank $03
                plp
                rts
                .endproc


;======================================
; Clear the arrow player
;======================================
ClearArrow      .proc
                .m16
                lda #$00                ; move to off-screen
                sta SP01_X_POS
                sta SP01_Y_POS

                .m8
                rts
                .endproc


;======================================
; Clear the Maltakreuze
;======================================
ClearMaltakreuze .proc
                .m16
                lda #$00                ; move to off-screen
                sta SP02_X_POS
                sta SP02_Y_POS

                .m8
                lda #$00                ; cross is not visible
                sta CrossFlag
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
                beq _1                  ; finished once we hit the first space character

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
                beq _1                  ; finished once we hit the first space character

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
