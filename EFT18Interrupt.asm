;===================================================================
;===================================================================
;EFT VERSION 1.8I (INTERRUPT) 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;===================================================================

START           = $6E00

;======================================
;Page zero RAM
;======================================
RTCLKL          = $14
ATRACT          = $4D
DRKMSK          = $4E
COLRSH          = $4F

;--------------------------------------
;--------------------------------------
                * = $B0
;--------------------------------------

;
;These locations are used by the interrupt service routine
;
DLSTPT          .word ?                 ; Zero page pointer to display list
MAPLO           .byte ?
MAPHI           .byte ?
CORPS           .byte ?                 ; number of unit under window
CURSXL          .byte ?
CURSXH          .byte ?
CURSYL          .byte ?                 ; cursor coordinates on screen (map frame)
CURSYH          .byte ?
OFFLO           .byte ?                 ; How far to offset new LMS value
OFFHI           .byte ?
TEMPI           .byte ?                 ; An all-purpose temporary register
CNT1            .byte ?                 ; DLI counter
CNT2            .byte ?                 ; DLI counter for movable map DLI
CHUNKX          .byte ?                 ; cursor coordinates (pixel frame)
CHUNKY          .byte ?

;
;THIS VALUE IS USED BY MAINLINE ROUTINE AND INTERRUPT
;
TURN            = $C9

;
;OS locations (see OS manual)
;
PCOLR0          = $02C0
STICK           = $0278
CH              = $2FC

;
;HARDWARE LOCATIONS
;
HPOSP0          = $D000
HPOSP1          = $D001
HPOSP2          = $D002
HPOSP3          = $D003
TRIG0           = $D010
TRIG1           = $D011
TRIG2           = $D012
COLPF0          = $D016
COLPF1          = $D017
COLPF2          = $D018
COLBAK          = $D01A
CONSOL          = $D01F

AUDF1           = $D200
AUDC1           = $D201

HSCROLL         = $D404
VSCROLL         = $D405
WSYNC           = $D40A
CHBASE          = $D409

SETVBV          = $E45C
XITVBV          = $E462

;
;Page 6 usage
;

;--------------------------------------
;--------------------------------------
                * = $0600
;--------------------------------------
;first come locations used by the interrupt service routine
XPOSL           .byte ?                 ; Horizontal position of
YPOSL           .byte ?                 ; Vertical position of
YPOSH           .byte ?                 ; upper-left corner of screen window
SCY             .byte ?                 ; vert position of cursor (player frame)
SHPOS0          .byte ?                 ; shadows player 0 position
TRCOLR          .byte ?
EARTH           .byte ?
ICELAT          .byte ?
SEASN1          .byte ?
SEASN2          .byte ?
SEASN3          .byte ?
DAY             .byte ?
MONTH           .byte ?
YEAR            .byte ?
BUTFLG          .byte ?
BUTMSK          .byte ?
TYL             .byte ?
TYH             .byte ?
DELAY           .byte ?                 ; acceleration delay on scrolling
TIMSCL          .byte ?                 ; frame to scroll in
TEMPLO          .byte ?                 ; temporary
TEMPHI          .byte ?
BASEX           .byte ?                 ; start position for arrow (player frame)
BASEY           .byte ?
STEPX           .byte ?                 ; intermediate position of arrow
STEPY           .byte ?
STPCNT          .byte ?                 ; which intermediate steps arrow is on
ORDCNT          .byte ?                 ; which order arrow is showing
ORD1            .byte ?                 ; orders record
ORD2            .byte ?
ARRNDX          .byte ?                 ; arrow index
HOWMNY          .byte ?                 ; how many orders for unit under cursor
KRZX            .byte ?                 ; maltakreuze coords (player frame)
KRZY            .byte ?
DBTIMR          .byte ?                 ; joystick debounce timer
STICKI          .byte ?                 ; coded value of stick direction (0-3)
ERRFLG          .byte ?
KRZFLG          .byte ?
STKFLG          .byte ?
HITFLG          .byte ?
TXL             .byte ?                 ; temporary values---slightly shifted
TXH             .byte ?
HANDCP          = $68F

;--------------------------------------
;--------------------------------------
                * = $5200
;--------------------------------------
PLYR0           .fill 128
PLYR1           .fill 128
PLYR2           .fill 128
PLYR3           .fill 128
CorpsX          .fill 159               ; x-coords of all units (pixel frame)
CorpsY          .fill 159               ; y-coords of all units (pixel frame)
MusterStrength  .fill 159               ; muster strengths
CombatStrength  .fill 159               ; combat strengths
SWAP            .fill 159               ; terrain code underneath unit
ArrivalTurn     .fill 159               ; turn of arrival
WordsTbl        .fill 272               ; various words for messages
CorpType        .fill 159               ; codes for unit types
CorpNumber      .fill 159               ; ID numbers of units
HundredDigit    .fill 256               ; tables for displaying numbers (hundreds)
TensDigit       .fill 256               ; tens tables
OnesDigit       .fill 256               ; ones tables
TxtTbl          .fill 96                ; more text
DaysInMonth     .fill 13                ; table of month lengths
HowManyOrders   .fill 159               ; how many orders each unit has in queue
WhatOrders      .fill 159               ; what the orders are
WHORDH          .fill 159
BEEPTB          .fill 4                 ; table of beep tones
ERRMSG          .fill 128               ; table of error messages
XOFF            .fill 4                 ; offsets for moving maltakreuze
YOFF            .fill 4
MASKO           .fill 4                 ; mask values for decoding orders
XADD            .fill 4                 ; offsets for moving arrow
YADD            .fill 4
TreeColors      .fill 13
MLTKRZ          .fill 8                 ; maltese cross shape
;
;RAM from $6000 to $6430 is taken up by
;character sets and the display list
;
;--------------------------------------
;--------------------------------------
                * = $6431
;--------------------------------------
ArrowTbl        .fill 32                ; arrow shapes

;--------------------------------------
;--------------------------------------
                * = $6450
;--------------------------------------

;--------------------------------------
;--------------------------------------
TXTWDW          * = $6CB1
;--------------------------------------

STKTAB          .fill 16                ; a joystick decoding table
SSNCOD          .fill 12
TRNTAB          .fill 60
BHX1            .fill 22
BHY1            .fill 22
BHX2            .fill 22
BHY2            .fill 22
EXEC            .fill 159

;
;everything in here is taken up by the map data
;
;
;This is the vertical blank interrupt routine
;It reads the joystick and scrolls the screen
;
;--------------------------------------
;--------------------------------------
                * = $7400
;--------------------------------------
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; added for binary compatibility
                ;LDA TRIG1               ; check for break button
                LDA #$FF
                NOP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

                BNE Z30                 ; no, check next
                LDY #62                 ; reset 60 Hertz vector
                LDX #233
                LDA #7
                JSR SETVBV
                PLA                     ; reset stack
                PLA
                PLA
                JMP $7210               ; break routine
Z30             LDA HANDCP
                BEQ A31
                LDA TRIG0
                BEQ A31
                LDA #$08
                STA CONSOL
                LDA CONSOL
                AND #$04
                BNE A31
                STA HANDCP
                LDA #$30
                STA $7B7A               ; my trademark
                LDX #$36
LOOPJ           LDA MusterStrength,X
                STA TEMPI
                LSR A
                ADC TEMPI
                BCC A22
                LDA #$FF
A22             STA MusterStrength,X
                DEX
                BNE LOOPJ


A31             LDA TRIG0               ; button status
                ORA BUTMSK              ; button allowed?
                BEQ X17
                LDA BUTFLG              ; no button now; previous status
                BNE X23
                JMP NOBUT
X23             LDA #$58                ; button just released
                STA PCOLR0
                LDA #$00
                STA BUTFLG
                STA KRZFLG
                STA AUDC1
                LDX #$52
LOOP8           STA TXTWDW+8,X          ; clear text window
                DEX
                BPL LOOP8
                LDA #$08
                STA DELAY
                CLC
                ADC RTCLKL
                STA TIMSCL
                JSR SWITCH
                LDA #$00
                STA CORPS
                JSR CLRP1
                JSR CLRP2
                JMP ENDISR
X17             STA ATRACT              ; button is pressed
                LDA STICK
                AND #$0F
                EOR #$0F
                BEQ X20                 ; joystick active?
                JMP ORDERS              ; yes
X20             STA DBTIMR              ; no, set debounce
                STA AUDC1
                STA STKFLG
                LDA BUTFLG
                BNE BUTHLD              ; is this the first button pass
                JMP FBUTPS              ; yes
BUTHLD          JSR ERRCLR              ; no, clear errors
X61             LDA HITFLG
                BEQ X63                 ; anybody in the window?
                JMP ENDISR              ; no
X63             LDA CH
                CMP #$21
                BNE X80                 ; space bar pressed?
                LDX CORPS               ; yes, check for Russian
                CPX #$37
                BCS X80
                LDA #$00
                STA CH
                STA HowManyOrders,X            ; clear out orders
                STA HOWMNY
                STA STPCNT
                LDA #$01
                STA ORDCNT
                JSR CLRP1
                JSR CLRP2
                LDA BASEX
                STA STEPX
                LDA BASEY
                STA STEPY
X80             LDA RTCLKL
                AND #$03
                BEQ X54                 ; time to move arrow?
                JMP ENDISR              ; no
X54             LDY HOWMNY              ; yes
                BNE X65                 ; any orders to show?
                JMP PCURSE              ; no, go ahead to maltakreuze
X65             JSR CLRP1               ; yes, clear old arrow
                LDA ORDCNT
                LDX #$00                ; assume first byte
                CMP #$05
                BCC X52                 ; second byte or first?
                INX                     ; second byte
X52             AND #$03                ; isolate bit pair index
                TAY
                LDA BITTAB,Y            ; get mask
X50             AND ORD1,X              ; get orders

;
;right justify orders
;
                DEY
                BPL X51
                LDY #$03
X51             BEQ X53
LOOP21          LSR A
                LSR A
                DEY
                BNE LOOP21
X53             STA ARRNDX
                ASL A
                ASL A
                ASL A

;get arrow image and store it to player RAM
                TAX
                LDY STEPY
X55             LDA ArrowTbl,X
                CPY #$80
                BCS X43
                STA PLYR1,Y
X43             INX
                INY
                TXA
                AND #$07
                BNE X55

                LDA STEPX               ; position arrow
                STA HPOSP1
;
;now step arrow
;
                LDX ARRNDX
                LDA STEPX
                CLC
                ADC XADD,X
                STA STEPX
                LDA STEPY
                CLC
                ADC YADD,X
                STA STEPY

                INC STPCNT              ; next step
                LDA STPCNT
                AND #$07
                BNE X59                 ; if not done end ISR
                STA STPCNT              ; end of steps
                INC ORDCNT              ; next order
                LDA ORDCNT
                CMP HOWMNY              ; last order?
                BCC X59                 ; no, out
                BEQ X59                 ; no, out
                LDA #$01
                STA ORDCNT              ;yes, reset to start of arrow's path

;
;display maltese cross ('maltakreuze' or KRZ)
;
PCURSE          LDY STEPY
                STY KRZY
                LDA #$FF
                STA KRZFLG
                LDX #$00
LOOP24          LDA MLTKRZ,X
                CPY #$80
                BCS X44
                STA PLYR2,Y
X44             INY
                INX
                CPX #$08
                BNE LOOP24
                LDA STEPX
                SEC
                SBC #$01
                STA KRZX
                STA HPOSP2
                JSR CLRP1               ; clear arrow
                LDA BASEX               ;reset arrow's coords
                STA STEPX
                LDA BASEY
                STA STEPY

X59             JMP ENDISR

;
;FIRST BUTTON PASS
;looks for a unit inside cursor
;if there is one, puts unit info into text window
;
FBUTPS          LDA #$FF
                STA BUTFLG

;
;first get coords of center of cursor (map frame)
;
X24             LDA CURSXL
                CLC
                ADC #$06
                STA TXL
                LDA CURSXH
                ADC #$00
                STA TXH
                LDA CURSYL
                CLC
                ADC #$09
                STA TYL
                LDA CURSYH
                ADC #$00
                STA TYH
                LDA TXH
                LSR A
                LDA TXL
                ROR A
                LSR A
                LSR A

;
;coords of cursor (pixel frame)
;
                STA CHUNKX
                LDA TYH
                LSR A
                TAX
                LDA TYL
                ROR A
                TAY
                TXA
                LSR A
                TYA
                ROR A
                LSR A
                LSR A
                STA CHUNKY

;
;now look for a match with unit coordinates
;
                LDX #$9E
LOOP6           CMP CorpsY,X
                BEQ MAYBE
X16             DEX
                BNE LOOP6
                STX CORPS               ; no match obtained
                DEX
                STX HITFLG
                JMP ENDISR

MAYBE           LDA CHUNKX
                CMP CorpsX,X
                BNE X35
                LDA ArrivalTurn,X
                BMI X35
                CMP TURN
                BCC MATCH
                BEQ MATCH
X35             LDA CHUNKY
                JMP X16

;
;match obtained
;
MATCH           LDA #$00
                STA HITFLG              ; note match
                STA CH
                LDA #$5C
                STA PCOLR0              ; light up cursor

;
;display unit specs
;
                STX CORPS
                LDY #$0D
                LDA CorpNumber,X        ; ID number
                JSR DNUMBR
                INY
                LDX CORPS
                LDA CorpType,X          ; first name
                STA TEMPI
                AND #$F0
                LSR A
                JSR ENTRY2
                LDA TEMPI
                AND #$0F                ; second name
                CLC
                ADC #$08
                JSR DWORDS
                LDA #$1E
                LDX CORPS
                CPX #$37
                BCS X26
                LDA #$1D
X26             JSR DWORDS              ; display unit size (corps or army)
                LDY #$38
                LDA #$1F                ; "MUSTER"
                JSR DWORDS
                DEY
                LDA #$1A                ; ":"
                STA TXTWDW,Y
                INY
                INY
                LDX CORPS
                LDA MusterStrength,X    ; muster strength
                JSR DNUMBR
                INY
                INY
                LDA #$20                ; "COMBAT"
                JSR DWORDS
                LDA #$21                ; "STRENGTH"
                JSR DWORDS
                DEY
                LDA #$1A                ; ":"
                STA TXTWDW,Y
                INY
                INY
                LDX CORPS
                LDA CombatStrength,X    ; combat strength
                JSR DNUMBR
X27             JSR SWITCH              ; flip unit with terrain
                LDA CORPS
                CMP #$37
                BCC X79                 ; Russian?
                LDA #$FF                ; yes, mask orders and exit
                STA HITFLG
                BMI X75
;
;German unit
;set up orders display
;first calculate starting coords (BASEX, BASEY)
;
X79             LDA #$01
                STA ORDCNT
                LDA #$00
                STA STPCNT

                LDA TXL
                AND #$07
                CLC
                ADC #$01
                CLC
                ADC SHPOS0
                STA BASEX
                STA STEPX

                LDA TYL
                AND #$0F
                LSR A
                SEC
                SBC #$01
                CLC
                ADC SCY
                STA BASEY
                STA STEPY
;
;now set up page 6 values
;
                LDX CORPS
                LDA HowManyOrders,X
                STA HOWMNY
                LDA WhatOrders,X
                STA ORD1
                LDA WHORDH,X
                STA ORD2
X75             JMP ENDISR
;
;ORDERS INPUT ROUTINE
;
ORDERS          LDA STKFLG
                BNE X75
                LDX CORPS
                CPX #$37
                BCC X64                 ; Russian?
                LDX #$00                ; yes, error
                JMP SQUAWK
X64             LDA HowManyOrders,X
                CMP #$08
                BCC X66                 ; only 8 orders allowed
                LDX #$20
                JMP SQUAWK
X66             LDA KRZFLG
                BNE X67                 ; must wait for maltakreuze
                LDX #$40
                JMP SQUAWK
X67             INC DBTIMR
                LDA DBTIMR              ; wait for debounce time
                CMP #$10
                BCS X68
                BCC X75
X68             LDA #$00
                STA DBTIMR              ; reset debounce timer
                LDX STICK
                LDA STKTAB,X
                BPL X69
                LDX #$60                ; no diagonal orders allowed
                JMP SQUAWK
;
;OK, this is a good order
;
X69             TAY
                STA STICKI
                LDA BEEPTB,Y
                STA AUDF1               ; "BEEP!"
                LDA #$A8
                STA AUDC1
                LDA #$FF
                STA STKFLG

                LDX CORPS
                INC HowManyOrders,X
                LDA HowManyOrders,X
                STA HOWMNY
                SEC
                SBC #$01
                AND #$03
                TAY
                STY TEMPI
                LDA HowManyOrders,X
                SEC
                SBC #$01
                LSR A
                LSR A
                TAX
                LDA STICKI
;isolate order
X71             DEY
                BMI X70
                ASL A
                ASL A
                JMP X71
X70             LDY TEMPI
                EOR ORD1,X              ; fold in new order (sneaky code)
                AND MASKO,Y
                EOR ORD1,X
                STA ORD1,X
                LDA ORD1
                LDX CORPS
                STA WhatOrders,X
                LDA ORD2
                STA WHORDH,X
;
;move maltakreuze
;
                JSR CLRP2
                LDX STICKI
                LDA KRZX
                CLC
                ADC XOFF,X
                STA KRZX
                LDA KRZY
                CLC
                ADC YOFF,X
                STA KRZY
DSPKRZ          LDA KRZX                ; display it
                STA HPOSP2
                LDY KRZY
                LDX #$00
LOOP26          LDA MLTKRZ,X
                CPY #$80
                BCS X45
                STA PLYR2,Y
X45             INY
                INX
                CPX #$08
                BNE LOOP26
                BEQ EXITI
;
;ERROR on inputs routine
;squawks speaker and puts out error message
;
SQUAWK          LDY #$69
LOOP28          LDA ERRMSG,X
                SEC
                SBC #$20
                STA TXTWDW,Y
                INY
                INX
                TXA
                AND #$1F
                BNE LOOP28
                LDA #$68
                STA AUDC1
                LDA #$50
                STA AUDF1               ; "HONK!"
                LDA #$FF
                STA ERRFLG
                BMI EXITI
;
;NO BUTTON PRESSED ROUTINE
;
NOBUT           STA DBTIMR
                LDA STICK
                AND #$0F
                EOR #$0F
                BNE SCROLL
                STA AUDC1
                STA STKFLG
                LDA #$08
                STA DELAY
                CLC
                ADC RTCLKL
                STA TIMSCL
                JSR ERRCLR
EXITI           JMP ENDISR
SCROLL          LDA #$00
                STA ATRACT
;
;acceleration feature of cursor
;
                LDA TIMSCL
                CMP RTCLKL
                BNE EXITI
                LDA DELAY
                CMP #$01
                BEQ X21
                SEC
                SBC #$01
                STA DELAY
X21             CLC
                ADC RTCLKL
                STA TIMSCL

                LDA #$00
                STA OFFLO
                STA OFFHI               ; zero the offset

                LDA STICK               ; get joystick reading
                PHA                     ; save it on stack for other bit checks
                AND #$08                ; joystick left?
                BNE CHKRT               ; no, move on
                LDA CURSXL
                BNE X13
                LDX CURSXH
                BEQ CHKUP
X13             SEC
                SBC #$01
                STA CURSXL
                BCS X14
                DEC CURSXH
X14             LDA SHPOS0
                CMP #$BA
                BEQ X1
                CLC
                ADC #$01
                STA SHPOS0
                STA HPOSP0
                BNE CHKUP
X1              LDA XPOSL
                SEC                     ; decrement x-coordinate
                SBC #$01
                STA XPOSL
                AND #$07
                STA HSCROLL             ; fine scroll
                CMP #$07                ; scroll overflow?
                BNE CHKUP               ; no, move on
                INC OFFLO               ; yes, mark it for offset
                CLV
                BVC CHKUP               ; no point in checking for joystick right
CHKRT           PLA                     ; get back joystick byte
                PHA                     ; save it again
                AND #$04                ; joystick right?
                BNE CHKUP               ; no, move on
                LDA CURSXL
                CMP #$64
                BNE X12
                LDX CURSXH
                BNE CHKUP
X12             CLC
                ADC #$01
                STA CURSXL
                BCC X15
                INC CURSXH
X15             LDA SHPOS0
                CMP #$36
                BEQ X2
                SEC
                SBC #$01
                STA SHPOS0
                STA HPOSP0
                BNE CHKUP
X2              LDA XPOSL
                CLC                     ; no, increment x-coordinate
                ADC #$01
                STA XPOSL
X4              AND #$07
                STA HSCROLL             ; fine scroll
                BNE CHKUP               ; scroll overflow? if not, move on
                DEC OFFLO               ; yes, set up offset for character scroll
                DEC OFFHI
CHKUP           PLA                     ; joystick up?
                LSR A
                PHA
                BCS CHKDN               ; no, ramble on
                LDA CURSYL
                CMP #$5E
                BNE X3
                LDX CURSYH
                CPX #$02
                BEQ CHKDN
X3              INC CURSYL
                BNE X11
                INC CURSYH
X11             LDX SCY
                CPX #$1B
                BEQ X6
                INC CURSYL
                BNE X18
                INC CURSYH
X18             DEX
                STX SCY
                TXA
                CLC
                ADC #$12
                STA TEMPI
LOOP4           LDA PLYR0,X
                STA PLYR0-1,X
                INX
                CPX TEMPI
                BNE LOOP4
                BEQ CHKDN
X6              LDA YPOSL
                SEC
                SBC #$01
                BCS X7
                DEC YPOSH
X7              STA YPOSL
                AND #$0F
                STA VSCROLL             ; fine scroll
                CMP #$0F
                BNE CHKDN               ; scroll overflow? If not, amble on
                LDA OFFLO               ; yes, set up offset for character scroll
                SEC
                SBC #$30
                STA OFFLO
                LDA OFFHI
                SBC #$00
                STA OFFHI
CHKDN           PLA                     ; joystick down?
                LSR A
                BCS CHGDL               ; no, trudge on
                LDA CURSYL
                CMP #$02
                BNE X5
                LDX CURSYH
                BEQ CHGDL
X5              SEC
                SBC #$01
                STA CURSYL
                BCS X10
                DEC CURSYH
X10             LDX SCY
                CPX #$4E
                BEQ X8
                SEC
                SBC #$01
                STA CURSYL
                BCS X19
                DEC CURSYH
X19             INX
                STX SCY
                TXA
                CLC
                ADC #$12
                DEX
                DEX
                STX TEMPI
                TAX
LOOP5           LDA PLYR0-1,X
                STA PLYR0,X
                DEX
                CPX TEMPI
                BNE LOOP5
                BEQ CHGDL
X8              LDA YPOSL
                CLC                     ; no, decrement y-coordinate
                ADC #$01
                STA YPOSL
                BCC X9
                INC YPOSH
X9              AND #$0F
                STA VSCROLL             ; fine scroll
                BNE CHGDL               ; no, move on
                LDA OFFLO               ; yes, mark offset
                CLC
                ADC #$30
                STA OFFLO
                LDA OFFHI
                ADC #$00
                STA OFFHI
;
;In this loop we add the offset values to the existing
;LMS addresses of all display lines.
;This scrolls the characters.
;
CHGDL           LDY #$09
DLOOP           LDA (DLSTPT),Y
                CLC
                ADC OFFLO
                STA (DLSTPT),Y
                INY
                LDA (DLSTPT),Y
                ADC OFFHI
                STA (DLSTPT),Y
                INY
                INY
                CPY #$27
                BNE DLOOP

ENDISR          LDA YPOSH
                LSR A
                LDA YPOSL
                ROR A
                LSR A
                LSR A
                LSR A
                CMP #$11
                BCS X39
                LDA #$FF
                BMI X40
X39             CMP #$1A
                BCC X41
                LDA #$02
                BPL X40
X41             STA TEMPI
                INX
                LDA #$1D
                SEC
                SBC TEMPI
X40             STA CNT1
                LDA #$00
                STA CNT2
                JMP XITVBV              ; exit vertical blank routine

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
DWORDS          ASL A
                ASL A
                ASL A
                BCC ENTRY2
                TAX
BOOP20          LDA WordsTbl+256,X
                SEC
                SBC #$20
                BEQ BNDW
                STA TXTWDW,Y
                INY
                INX
                TXA
                AND #$07
                BNE BOOP20
BNDW            INY
                RTS
ENTRY2          TAX                     ; this is another entry point
LOOP20          LDA WordsTbl,X
                SEC
                SBC #$20
                BEQ NDW
                STA TXTWDW,Y
                INY
                INX
                TXA
                AND #$07
                BNE LOOP20
NDW             INY
                RTS

;
;SUBROUTINE SWITCH FOR SWAPPING CORPS WITH TERRAIN
;
SWITCH          LDA #$00
                STA MAPHI
                LDA #$27
                SEC
                SBC CHUNKY
                ASL A
                ROL MAPHI
                ASL A
                ROL MAPHI
                ASL A
                ROL MAPHI
                ASL A
                ROL MAPHI
                STA TEMPLO
                LDX MAPHI
                STX TEMPHI
                ASL A
                ROL MAPHI
                CLC
                ADC TEMPLO
                STA MAPLO
                LDA MAPHI
                ADC TEMPHI
                ADC #$65
                STA MAPHI
                LDA #46
                SEC
                SBC CHUNKX
                TAY
                LDA (MAPLO),Y
                LDX CORPS
                BEQ X34
                PHA
                LDA SWAP,X
                STA (MAPLO),Y
                PLA
                STA SWAP,X
X34             RTS
;
;SUBROUTINE CLRP1
;clears the arrow player
;
CLRP1           LDA #$00
                LDY STEPY
                DEY
                TAX
LOOP23          CPY #$80
                BCS X22
                STA PLYR1,Y
X22             INY
                INX
                CPX #$0B
                BNE LOOP23
                RTS
;
;SUBROUTINE CLRP2
;clears the maltakreuze
;
CLRP2           LDA #$00
                LDY KRZY
                TAX
LOOP25          CPY #$80
                BCS X42
                STA PLYR2,Y
X42             INY
                INX
                CPX #$0A
                BNE LOOP25
                RTS
;
;SUBROUTINE ERRCLR
;clears sound and the text window
;
ERRCLR          LDA ERRFLG
                BPL ENDERR
                LDA #$00
                STA ERRFLG
                LDY #$86
                LDX #$1F
LOOP29          STA TXTWDW,Y
                DEY
                DEX
                BPL LOOP29
ENDERR          RTS

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
;This is the DLI routine
;
;--------------------------------------
;--------------------------------------
                * = $7B00
;--------------------------------------
DLISRV          PHA
                TXA
                PHA
                INC CNT2
                LDA CNT2
                CMP CNT1
                BNE OVER1
                LDX #$62                ; map DLI
                LDA #$28
                EOR COLRSH
                AND DRKMSK
                STA WSYNC
                STX CHBASE
                STA COLPF0
                JMP DLIOUT

OVER1           CMP #$0F
                BNE OVER6
                LDA #$3A
                EOR COLRSH
                AND DRKMSK
                TAX
                LDA #$00
                EOR COLRSH
                AND DRKMSK
                STA WSYNC
                STX COLPF2
                STA COLPF1
                JMP DLIOUT

OVER6           CMP #$01
                BNE OVER2
                LDA TRCOLR              ; green tree color
                EOR COLRSH
                AND DRKMSK
                TAX
                LDA #$1A                ; yellow band at top of map
                EOR COLRSH
                AND DRKMSK
                STA WSYNC
                STA COLBAK
                STX COLPF0
                LDA #$60
                STA CHBASE
                JMP DLIOUT

OVER2           CMP #$03
                BNE OVER3
                LDA EARTH               ; top of map
                EOR COLRSH
                AND DRKMSK
                STA WSYNC
                STA COLBAK
                JMP DLIOUT

OVER3           CMP #$0D
                BNE OVER4
                LDX #$E0                ; bottom of map
                LDA #$22
                EOR COLRSH
                AND DRKMSK
                STA WSYNC
                STA COLPF2
                STX CHBASE
                JMP DLIOUT

OVER4           CMP #$0E
                BNE OVER5
                LDA #$8A                ; bright blue strip
                EOR COLRSH
                AND DRKMSK
                STA WSYNC
                STA COLBAK
                JMP DLIOUT

OVER5           CMP #$10
                BNE DLIOUT
                LDA #$D4                ; green bottom
                EOR COLRSH
                AND DRKMSK
                PHA                     ; some extra delay
                PLA
                NOP
                STA COLBAK

DLIOUT          PLA
                TAX
                PLA
                RTI
;
;SUBROUTINE DNUMBR
;displays a number with leading zero suppress
;
DNUMBR          TAX
                CLC
                LDA HundredDigit,X
                BEQ X36
                ADC #$10
                STA TXTWDW,Y
                INY
                SEC
X36             LDA TensDigit,X
                BCS X38
                BEQ X37
X38             CLC
                ADC #$10
                STA TXTWDW,Y
                INY
X37             LDA OnesDigit,X
                CLC
                ADC #$10
                STA TXTWDW,Y
                INY
                RTS

NDX             .byte 0,1,2,3,4,9,14,19
                .byte 24,23,22,21,20,15,10,5
                .byte 6,7,8,13,18,17,16,11
YINC            .byte 1
XINC            .byte 0,$FF,0,1
OFFNC           .byte 1,1,1,1,1,1,2,2,1,0

            .END
