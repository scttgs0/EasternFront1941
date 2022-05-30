;==================================================================
;==================================================================
;EFT VERSION 1.8M (MAINLINE) 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

                .include "equates_system_atari8.asm"
                .include "equates_directpage.asm"
                .include "equates_page6.asm"

;
;declarations of routines in other modules
;
CHKZOC          = $5140
LOGSTC          = $5091
DNUMBR          = $7BB2
DWORDS          = $79C0
SWITCH          = $79EF
YINC            = $7BF1
XINC            = $7BF2


;--------------------------------------
;--------------------------------------
                * = $5200
;--------------------------------------
PLYR0           .fill 512
CorpsX          .fill 159               ; x-coords of all units (pixel frame)
CorpsY          .fill 159               ; y-coords of all units (pixel frame)
MusterStrength  .fill 159               ; muster strengths
CombatStrength  .fill 159               ; combat strengths
SWAP            .fill 159               ; terrain code underneath unit
ArrivalTurn     .fill 159               ; turn of arrival

;--------------------------------------
;--------------------------------------
                * = $5C08
;--------------------------------------
OnesDigit       .fill 256
TxtTbl          .fill 96                ; more text
DaysInMonth     .fill 13                ; table of month lengths
HowManyOrders   .fill 159               ; how many orders each unit has in queue
WhatOrders      .fill 159               ; what the orders are
WHORDH          .fill 159

;--------------------------------------
;--------------------------------------
                * = $5FE2
;--------------------------------------
XADD            .fill 4                 ; offsets for moving arrow
YADD            .fill 4
TreeColors      .fill 13
MLTKRZ          .fill 8                 ; maltese cross shape


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
;This is the initialization program
;The program begins here
;

;--------------------------------------
;--------------------------------------
                * = $6E00
;--------------------------------------

START           LDX #$08
BOOP99          LDA ZPVAL,X             ; initialize page zero values
                STA DLSTPT,X
                LDA COLTAB,X
                STA PCOLR0,X
                DEX
                BPL BOOP99

                LDX #$0F
BOOP98          LDA PSXVAL,X            ; initialize page six values
                STA XPOSL,X
                DEX
                BPL BOOP98

                LDA #$00
                STA SDLSTL
                STA HSCROL
                STA VSCROL
                LDA DLSTPT+1
                STA SDLSTL+1

                LDX #$00
LOOP22          LDA MusterStrength,X
                STA CombatStrength,X
                LDA #$00
                STA HowManyOrders,X
                LDA #$FF
                STA EXEC,X
                INX
                CPX #$A0
                BNE LOOP22

;   set up player window
                LDA #$50
                STA PMBASE

;   here follow various initializations
                LDA #$2F
                STA SDMCTL
                LDA #$03
                STA GRACTL
                LDA #$78
                STA HPOSP0
                LDA #$01
                STA HANDCP
                STA GPRIOR
                STA SIZEP0
                LDX #$33

                LDA #$FF
                STA PLYR0,X
                INX
                STA PLYR0,X
                INX
                LDA #$81
LOOP2           STA PLYR0,X
                INX
                CPX #$3F
                BNE LOOP2
                LDA #$FF
                STA PLYR0,X
                STA TURN
                INX
                STA PLYR0,X

;   enable deferred vertical blank interrupt
                LDY #$00
                LDX #$74
                LDA #$07
                JSR SETVBV
                LDA #$00                ; This is DLI vector (low byte)
                STA $0200
                LDA #$7B
                STA $0201
                LDA #$C0
                STA NMIEN               ; Turn interrupts on

NEWTRN          INC TURN

;   first do calendar calculations
                LDA DAY
                CLC
                ADC #07
                LDX MONTH
                CMP DaysInMonth,X
                BEQ X28
                BCC X28
                CPX #$02
                BNE X96
                LDY YEAR
                CPY #44
                BNE X96
                SEC
                SBC #$01
X96             SEC
                SBC DaysInMonth,X
                INX
                CPX #13
                BNE X29
                INC YEAR
                LDX #01
X29             STX MONTH
                LDY TreeColors,X
                STY TRCOLR
X28             STA DAY
                LDY #$93
                LDA #$00
LOOP13          STA TXTWDW,Y
                INY
                CPY #$A7
                BNE LOOP13
                LDY #$93
                TXA
                CLC
                ADC #$10
                JSR DWORDS
                LDA DAY
                JSR DNUMBR
                LDA #$0C
                STA TXTWDW,Y
                INY
                INY
                LDA #$11
                STA TXTWDW,Y
                INY
                LDA #$19
                STA TXTWDW,Y
                INY
                LDX YEAR
                LDA #$14
                STA TXTWDW,Y
                INY
                LDA OnesDigit,X
                CLC
                ADC #$10
                STA TXTWDW,Y

;   do season calculations
                LDA MONTH
                CMP #$04
                BNE X87
                LDA #$02
                STA EARTH
                LDA #$40
                STA SEASN1
                LDA #$01
                STA SEASN3
                LDA #$00
                STA SEASN2
                JMP ENDSSN
X87             CMP #$0A
                BNE X88
                LDA #$02
                STA EARTH
                JMP ENDSSN
X88             CMP #$05
                BNE X89
                LDA #$10
                STA EARTH
                JMP ENDSSN
X89             CMP #$0B
                BNE X90
                LDA #$0A
                STA EARTH
                JMP X91
X90             CMP #$01
                BNE X92
                LDA #$80
                STA SEASN1
                LDA #$FF
                STA SEASN2
                STA SEASN3
                JMP ENDSSN
X92             CMP #$03
                BEQ X91
                JMP ENDSSN

;   freeze those rivers, baby
X91             LDA RANDOM
                AND #$07
                CLC
                ADC #$07
                EOR SEASN2
                STA TEMPR
                LDA ICELAT
                STA OLDLAT
                SEC
                SBC TEMPR
                BEQ X95
                BPL X94
X95             LDA #$01
X94             CMP #$27
                BCC X93
                LDA #$27
X93             STA ICELAT
                LDA #$01
                STA CHUNKX
                STA LONG
                LDA OLDLAT
                STA CHUNKY
                STA LAT

LOOP40          JSR TERR

                AND #$3F
                CMP #$0B
                BCC NOTCH
                CMP #$29
                BCS NOTCH
                LDX CHUNKY
                CPX #$0E
                BCS DOTCH
                CMP #$23
                BCS NOTCH
DOTCH           ORA SEASN1
                LDX UNITNO
                BEQ X86
                STA SWAP,X
                JMP NOTCH
X86             STA (MAPPTR),Y
NOTCH           INC CHUNKX
                LDA CHUNKX
                STA LONG
                CMP #46
                BNE LOOP40
                LDA #$00
                STA CHUNKX
                STA LONG
                LDA CHUNKY
                CMP ICELAT
                BEQ ENDSSN
                SEC
                SBC SEASN3
                STA CHUNKY
                STA LAT
                JMP LOOP40

ENDSSN          LDX #$9E                ; any reinforcements?
LOOP14          LDA ArrivalTurn,X
                CMP TURN
                BNE X33
                LDA CorpsX,X
                STA CHUNKX
                STA LONG
                LDA CorpsY,X
                STA CHUNKY
                STA LAT
                STX CORPS
                JSR TERRB
                BEQ SORRY
                CPX #$37
                BCS A51
                LDA #$0A
                STA TXTWDW+36
A51             JSR SWITCH
                JMP X33
SORRY           LDA TURN
                CLC
                ADC #$01
                STA ArrivalTurn,X
X33             DEX
                BNE LOOP14

X31             LDX #$9E
LOOPF           STX ARMY
                JSR LOGSTC              ; logistics subroutine
                LDX ARMY
                DEX
                BNE LOOPF

;   calculate some points
                LDA #$00
                STA ACCLO
                STA ACCHI
                LDX #$01
LOOPB           LDA #$30
                SEC
                SBC CorpsX,X
                STA TEMPR
                LDA MusterStrength,X
                LSR A
                BEQ A01
                TAY
                LDA #$00
                CLC
LOOPA           ADC TEMPR
                BCC A0
                INC ACCHI
                CLC
                BNE A0
                DEC ACCHI
A0              DEY
                BNE LOOPA
A01             INX
                CPX #$37
                BNE LOOPB

LOOPC           LDA CorpsX,X
                STA TEMPR
                LDA CombatStrength,X
                LSR A
                LSR A
                LSR A
                BEQ A02
                TAY
                LDA #$00
                CLC
LOOPD           ADC TEMPR
                BCC A03
                INC ACCLO
                CLC
                BNE A03
                DEC ACCLO
A03             DEY
                BNE LOOPD
A02             INX
                CPX #$9E
                BNE LOOPC

                LDA ACCHI
                SEC
                SBC ACCLO
                BCS A04
                LDA #$00
A04             LDX #$03
LOOPG           LDY MOSCOW,X
                BEQ A15
                CLC
                ADC MPTS,X
                BCC A15
                LDA #$FF
A15             DEX
                BPL LOOPG

                LDX HANDCP              ; was handicap option used?
                BNE A23                 ; no
                LSR A                   ; yes, halve score
A23             LDY #$05
                JSR DNUMBR
                LDA #$00
                STA TXTWDW,Y
                LDA TURN
                CMP #$28
                BNE Z00
                LDA #$01                ; end of game
                JSR TXTMSG
FINI            JMP FINI                ; hang up


Z00             LDA #$00
                STA BUTMSK
                STA CORPS
                JSR TXTMSG
                JSR $4700               ; artificial intelligence routine
                LDA #$01
                STA BUTMSK
                LDA #$02
                JSR TXTMSG

;   movement execution phase
                LDA #$00
                STA TICK
                LDX #$9E
LOOP31          STX ARMY
                JSR DINGO               ; determine first execution time
                DEX
                BNE LOOP31

LOOP33          LDX #$9E
LOOP32          STX ARMY
                LDA MusterStrength,X
                SEC
                SBC CombatStrength,X
                CMP #$02
                BCC Y30
                INC CombatStrength,X
                CMP RANDOM
                BCC Y30
                INC CombatStrength,X
Y30             LDA EXEC,X
                BMI A60
                CMP TICK
                BNE A60
                LDA WhatOrders,X
                AND #$03
                TAY
                LDA CorpsX,X
                CLC
                ADC XINC,Y
                STA LONG
                STA ACCLO
                LDA CorpsY,X
                CLC
                ADC YINC,Y
                STA LAT
                STA ACCHI
                JSR TERR
                LDA UNITNO
                BEQ DOMOVE
                CMP #$37
                BCC GERMAN
                LDA ARMY
                CMP #$37
                BCS TRJAM
                BCC COMBAT
GERMAN          LDA ARMY
                CMP #$37
                BCS COMBAT
TRJAM           LDX ARMY
                LDA TICK
                CLC
                ADC #$02
                STA EXEC,X
A60             JMP Y06
COMBAT          JSR $4ED8
                LDA VICTRY
                BEQ A60
                BNE Z94
DOMOVE          LDX ARMY
                STX CORPS
                LDA CorpsY,X
                STA CHUNKY
                STA LAT
                LDA CorpsX,X
                STA CHUNKX
                STA LONG
                JSR CHKZOC
                LDA ACCHI
                STA LAT
                LDA ACCLO
                STA LONG
                LDA ZOC
                CMP #$02
                BCC Z94
                JSR CHKZOC
                LDA ZOC
                CMP #$02
                BCS TRJAM
Z94             JSR SWITCH
                LDX CORPS
                LDA LAT
                STA CHUNKY
                STA CorpsY,X
                LDA LONG
                STA CHUNKX
                STA CorpsX,X
                JSR SWITCH
                LDX ARMY
                LDA #$FF
                STA EXEC,X
                DEC HowManyOrders,X
                BEQ Y06
                LSR WHORDH,X
                ROR WhatOrders,X
                LSR WHORDH,X
                ROR WhatOrders,X
                LDY #$03
LOOPH           LDA CorpsX,X
                CMP MOSCX,Y
                BNE A18
                LDA CorpsY,X
                CMP MOSCY,Y
                BNE A18
                LDA #$FF
                CPX #$37
                BCC A19
                LDA #$00
A19             STA MOSCOW,Y
A18             DEY
                BPL LOOPH

                JSR DINGO
                JSR STALL
Y06             LDX ARMY
                DEX
                BEQ Y07
                JMP LOOP32
Y07             INC TICK
                LDA TICK
                CMP #$20
                BEQ Y08
                JMP LOOP33

;   end of movement phase
Y08             JMP NEWTRN

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
STALL           LDA #$00
LOOP79          PHA
                PLA
                PHA
                PLA
                PHA
                PLA
                ADC #$01
                BNE LOOP79
                RTS

;
;this is the debugging routine
;it can't be reached by any route any longer
;

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; added for binary compatibility
                JMP $6E9A
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;--------------------------------------
;--------------------------------------
                * = $7210
;--------------------------------------
                LDA #$00
                STA $D01D
                STA $D00D
                STA $D00E
                STA $D00F
                LDA #$22
                STA $22F
                LDA #$20
                STA $230
                LDA #$BC
                STA $231
                LDA #$40
                STA NMIEN
                LDA #$0A
                STA $2C5
                LDA #$00
                STA $5FFF
                STA $2C8
                BRK


;
;Subroutine TERR determines what terrain is in a square
;

;--------------------------------------
;--------------------------------------
                * = $7240
;--------------------------------------

TERR            JSR TERRB
                BEQ LOOKUP
                RTS
TERRB           LDA #$00
                STA MAPPTR+1
                STA UNITNO
                LDA #$27
                SEC
                SBC LAT
                ASL A
                ROL MAPPTR+1
                ASL A
                ROL MAPPTR+1
                ASL A
                ROL MAPPTR+1
                ASL A
                ROL MAPPTR+1
                STA TLO
                LDY MAPPTR+1
                STY THI
                ASL A
                ROL MAPPTR+1
                CLC
                ADC TLO
                STA MAPPTR
                LDA MAPPTR+1
                ADC THI
                ADC #$65
                STA MAPPTR+1
                LDA #46
                SEC
                SBC LONG
                TAY
                LDA (MAPPTR),Y
                STA TRNCOD
                AND #$3F
                CMP #$3D
                BEQ A80
                CMP #$3E
A80             RTS

LOOKUP          LDA TRNCOD
                STA UNTCOD
                AND #$C0
                LDX #$9E
                CMP #$40
                BNE X98
                LDX #$37
X98             LDA LAT
LOOP30          CMP CorpsY,X
                BEQ MIGHTB
X97             DEX
                BNE LOOP30
                LDA #$FF
                STA TXTWDW+128
                BMI MATCH
MIGHTB          LDA LONG
                CMP CorpsX,X
                BNE X99
                LDA CombatStrength,X
                BEQ X99
                LDA ArrivalTurn,X
                BMI X99
                CMP TURN
                BCC MATCH
                BEQ MATCH
X99             LDA LAT
                JMP X97
MATCH           STX UNITNO
                LDA SWAP,X
                STA TRNCOD
                RTS

;   determines execution time of next move
DINGO           LDX ARMY
                LDA HowManyOrders,X
                BNE Y00
                LDA #$FF
                STA EXEC,X
                RTS
Y00             LDA CorpsX,X
                STA LONG
                LDA CorpsY,X
                STA LAT
                JSR TERR
                LDA UNTCOD
                STA UNTCD1
                LDX ARMY
                LDA WhatOrders,X
                EOR #$02
                AND #$03
                TAY
                LDA CorpsX,X
                CLC
                ADC XADD,Y
                STA LONG
                LDA CorpsY,X
                CLC
                ADC YADD,Y
                STA LAT
                JSR TERR
                JSR TERRTY
                LDA UNTCD1
                AND #$3F
                LDX #$00
                CMP #$3D
                BEQ Y01                 ; infantry
                LDX #$0A                ; armor
Y01             TXA
                LDX MONTH
                CLC
                ADC SSNCOD-1,X          ; add season index
                ADC TRNTYP              ; add terrain index
                TAX
                LDA TRNTAB,X            ; get net delay
                CLC
                ADC TICK
                LDX ARMY
                STA EXEC,X
                LDA TRNTYP
                CMP #$07
                BCC Y02
                LDY #$15
LOOP35          LDA LAT
                CMP BHY1,Y
                BNE Y03
                LDA LONG
                CMP BHX1,Y
                BNE Y03
                LDX ARMY
                LDA CorpsX,X
                CMP BHX2,Y
                BNE Y03
                LDA CorpsY,X
                CMP BHY2,Y
                BNE Y03
                LDA #$FF
                STA EXEC,X
                RTS
Y03             DEY
                BPL LOOP35
Y02             RTS

;
;this subroutine determines the type of terrain
;in a square
;
TERRTY          LDY #$00
                LDA TRNCOD
                BEQ DONE
                CMP #$7F                ; border?
                BNE Y04
                LDY #$09
                BNE DONE
Y04             INY
                CMP #$07                ; mountain?
                BCC DONE
                INY
                CMP #$4B                ; city?
                BCC DONE
                INY
                CMP #$4F                ; frozen swamp?
                BCC DONE
                INY
                CMP #$69                ; frozen river?
                BCC DONE
                INY
                CMP #$8F                ; swamp?
                BCC DONE
                INY
                CMP #$A4                ; river?
                BCC DONE
                LDX LAT
                CPX #$0E
                BCC NEXT
                CMP #$A9
                BCC DONE
NEXT            INY
                CMP #$BA                ; coastline?
                BCC DONE
                CPX #$0E
                BCC NEXT2
                CMP #$BB
                BCC DONE
NEXT2           INY
                CMP #$BD                ; estuary?
                BCC DONE
                INY
DONE            STY TRNTYP
                RTS

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

TXTMSG          ASL A
                ASL A
                ASL A
                ASL A
                ASL A
                TAX
                LDY #$69
LOOP19          LDA TxtTbl,X
                SEC
                SBC #$20
                STA TXTWDW,Y
                INY
                INX
                TXA
                AND #$1F
                BNE LOOP19
                RTS

                .fill 3,$00     ; added for compatibility

            .END
