
; SPDX-FileName: platform_f256.asm
; SPDX-FileCopyrightText: Copyright 2023-2025, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;======================================
; seed = quick and dirty
;--------------------------------------
; preserve      A
;======================================
RandomSeedQuick .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda RTC_MIN
                sta RNG_SEED+1

                lda RTC_SEC
                sta RNG_SEED

                lda #rcEnable|rcDV      ; cycle the DV bit
                sta RNG_CTRL
                lda #rcEnable
                sta RNG_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; seed = elapsed seconds this hour
;--------------------------------------
; preserve      A
;======================================
RandomSeed      .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda RTC_MIN
                jsr Bcd2Bin
                sta RND_MIN

                lda RTC_SEC
                jsr Bcd2Bin
                sta RND_SEC

;   elapsed minutes * 60
                lda RND_MIN
                asl
                asl
                pha
                asl
                pha
                asl
                pha
                asl
                sta RND_RESULT      ; *32

                pla
                clc
                adc RND_RESULT      ; *16
                sta RND_RESULT

                pla
                clc
                adc RND_RESULT      ; *8
                sta RND_RESULT

                pla
                clc
                adc RND_RESULT      ; *4
                sta RND_RESULT

;   add the elapsed seconds
                clc
                lda RND_SEC
                adc RND_RESULT

                sta RNG_SEED_LO
                stz RNG_SEED_HI

                lda #rcEnable|rcDV      ; cycle the DV bit
                sta RNG_CTRL
                lda #rcEnable
                sta RNG_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Convert BCD to Binary
;======================================
Bcd2Bin         .proc
                pha

;   upper-nibble * 10
                lsr
                pha                     ; n*2
                lsr
                lsr                     ; n*8
                sta _tmp

                pla                     ; A=n*2
                clc
                adc _tmp                ; A=n*8+n*2 := n*10
                sta _tmp

;   add the lower-nibble
                pla
                and #$0F
                clc
                adc _tmp

                rts

;--------------------------------------

_tmp            .byte $00

                .endproc


;======================================
; Convert Binary to BCD
;======================================
Bin2Bcd         .proc
                ldx #00
                ldy #00
_next1          cmp #10
                bcc _done

                sec
                sbc #10

                inx
                bra _next1

_done           tay
                txa
                asl
                asl
                asl
                asl
                and #$F0
                sta _tmp

                tya
                clc
                adc _tmp

                rts

;--------------------------------------

_tmp            .byte $00

                .endproc


;======================================
; Convert Binary to Ascii
;--------------------------------------
; on entry:
;   A           byte value
; on exit:
;   Y,A         2-byte ascii value
;======================================
Bin2Ascii       .proc
                pha

;   upper-nibble to ascii
                lsr
                lsr
                lsr
                lsr
                and #$0F
                tax
                ldy _hex,X

;   lower-nibble to ascii
                pla
                and #$0F
                tax
                lda _hex,X

                rts

;--------------------------------------

_hex            .text '0123456789ABCDEF'

                .endproc

;======================================
; Initialize SID
;--------------------------------------
; preserve      A, X
;======================================
InitSID         .proc
                pha
                phx

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda #0                  ; reset the SID registers
                ldx #$1F
_next1          sta SID1_BASE,X
                sta SID2_BASE,X

                dex
                bpl _next1

                lda #sidAttack2ms|sidDecay750ms
                sta SID1_ATDCY1
                sta SID1_ATDCY2
                sta SID1_ATDCY3
                sta SID2_ATDCY1

                ; 0%|sidDecay6ms
                stz SID1_SUREL1         ; Sustain/Release = 0 [square wave]
                stz SID1_SUREL2
                stz SID1_SUREL3
                stz SID2_SUREL1

                lda #sidcSaw|sidcGate
                sta SID1_CTRL1
                sta SID1_CTRL2
                sta SID1_CTRL3
                sta SID2_CTRL1

                lda #$08                ; Volume = 8 (mid-range)
                sta SID1_SIGVOL
                sta SID2_SIGVOL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                plx
                pla
                rts
                .endproc


;======================================
; Initialize PSG
;--------------------------------------
; preserve      A, X
;======================================
InitPSG         .proc
                pha
                phx

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda #0                  ; reset the PSG registers
                ldx #$07
_next1          sta PSG1_BASE,X
                sta PSG2_BASE,X

                dex
                bpl _next1

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                plx
                pla
                rts
                .endproc


;======================================
; Initialize the text-color LUT
;--------------------------------------
; preserve      A, Y
;======================================
InitTextPalette .proc
                pha
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                ldy #$3F
_next1          lda _Text_CLUT,Y
                sta FG_CHAR_LUT_PTR,Y   ; same palette for foreground and background
                sta BG_CHAR_LUT_PTR,Y

                dey
                bpl _next1

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                pla
                rts

;--------------------------------------

_Text_CLUT      .dword $00282828        ; 0: Dark Jungle Green
                .dword $00DDDDDD        ; 1: Gainsboro
                .dword $00143382        ; 2: Saint Patrick Blue
                .dword $006B89D7        ; 3: Blue Gray
                .dword $00693972        ; 4: Indigo
                .dword $00B561C2        ; 5: Deep Fuchsia
                .dword $00352BB0        ; 6: Blue Pigment
                .dword $007A7990        ; 7: Fern Green
                .dword $0074D169        ; 8: Moss Green
                .dword $00E6E600        ; 9: Peridot
                .dword $00C563BD        ; A: Pastel Violet
                .dword $005B8B46        ; B: Han Blue
                .dword $00BC605E        ; C: Medium Carmine
                .dword $00C9A765        ; D: Satin Sheen Gold
                .dword $0004750E        ; E: Hookers Green
                .dword $00BC605E        ; F: Medium Carmine

                .endproc


;======================================
; Initialize the graphic-color LUT
;--------------------------------------
; preserve      A, Y
;======================================
InitGfxPalette  .proc
                pha
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to graphic map
                lda #$01
                sta IOPAGE_CTRL

                ldy #$3F
_next1          lda Palette,Y
                sta GRPH_LUT0_PTR,Y

                lda Palette+$40,Y
                sta GRPH_LUT1_PTR,Y

                dey
                bpl _next1

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                pla
                rts
                .endproc


;======================================
; Load the pixel data for the tiles
; into video memory.
; Set it up for tile set 0
;======================================
InitTiles       .proc
map             = $01_0000
tiles           = $05_0000
;---

                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   define the tilesets
                lda #<tiles             ; Set the source address
                sta TILESET0_ADDR
                lda #>tiles
                sta TILESET0_ADDR+1
                lda #`tiles
                sta TILESET0_ADDR+2

;   enable the tileset, use 8x256 pixel source data layout
                lda #tsVertical
                sta TILESET0_CTRL

;   define the tile map
                lda #<map
                sta TILE0_ADDR
                lda #>map
                sta TILE0_ADDR+1
                lda #`map
                sta TILE0_ADDR+2

                lda #50
                sta TILE0_SIZE_X
                stz TILE0_SIZE_X+1
                lda #43
                sta TILE0_SIZE_Y
                stz TILE0_SIZE_Y+1

                stz TILE0_SCROLL_X+1
                stz TILE0_SCROLL_X
                stz TILE0_SCROLL_Y+1
                stz TILE0_SCROLL_Y

;   enable the tile map, use 8x8-pixel tiles
                lda #tcEnable|tcSmallTiles
                sta TILE0_CTRL

;   enable on layer 0
                lda #locLayer0_TL0
                sta LAYER_ORDER_CTRL_0

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;--------------------------------------
; sprites dimensions are 32x32 (1024)
;--------------------------------------
; preserve      A
;======================================
; InitSprites     .proc
;                 pha

; ;   preserve IOPAGE control
;                 lda IOPAGE_CTRL
;                 pha

; ;   switch to system map
;                 stz IOPAGE_CTRL

; ;   set player sprites (sprite-00 & sprint-01)
;                 .frsSpriteInit SPR_PLAYER, scEnable|scLUT0|scDEPTH0|scSIZE_16, 0
;                 .frsSpriteInit SPR_PLAYER, scEnable|scLUT0|scDEPTH0|scSIZE_16, 1

; ;   set bomb sprites (sprite-02 & sprint-03)
;                 .frsSpriteInit SPR_PLAYER, scEnable|scLUT0|scDEPTH0|scSIZE_16, 2
;                 .frsSpriteInit SPR_PLAYER, scEnable|scLUT0|scDEPTH0|scSIZE_16, 3

; ;   restore IOPAGE control
;                 pla
;                 sta IOPAGE_CTRL

;                 pla
;                 rts
;                 .endproc


;======================================
; Clear all Sprites
;======================================
ClearSprites    .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 0
                .frsSpriteClear 1
                .frsSpriteClear 2
                .frsSpriteClear 3

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
;
;======================================
InitBitmap      .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                ;lda #<ScreenRAM         ; Set the destination address
                sta BITMAP2_ADDR
                ;lda #>ScreenRAM
                sta BITMAP2_ADDR+1
                ;lda #`ScreenRAM
                sta BITMAP2_ADDR+2

                lda #bmcEnable|bmcLUT0
                sta BITMAP2_CTRL

                lda #locLayer2_BM2
                sta LAYER_ORDER_CTRL_1

                stz BITMAP0_CTRL        ; disabled
                stz BITMAP1_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Clear the play area of the screen
;--------------------------------------
; preserve      A, X, Y
;======================================
ClearScreen     .proc
v_QtyPages      .var $05                ; 40x30 = $4B0... 4 pages + 176 bytes
v_EmptyText     .var $00
v_TextColor     .var $40
;---

                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   clear color
                lda #<CS_COLOR_MEM_PTR
                sta zpDest
                lda #>CS_COLOR_MEM_PTR
                sta zpDest+1
                stz zpDest+2

                ldx #v_QtyPages
                lda #v_TextColor
_nextPageC      ldy #$00
_nextByteC      sta (zpDest),Y

                iny
                bne _nextByteC

                inc zpDest+1            ; advance to next memory page

                dex
                bne _nextPageC

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

;   clear text
                lda #<CS_TEXT_MEM_PTR
                sta zpDest
                lda #>CS_TEXT_MEM_PTR
                sta zpDest+1

                ldx #v_QtyPages
                lda #v_EmptyText
_nextPageT      ldy #$00
_nextByteT      sta (zpDest),Y

                iny
                bne _nextByteT

                inc zpDest+1            ; advance to next memory page

                dex
                bne _nextPageT

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Render Debug Info
;--------------------------------------
; preserve      A, X, Y
;======================================
RenderDebug     .proc
v_RenderLine    .var 0*CharResX
;---

                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to color map
                lda #iopPage3
                sta IOPAGE_CTRL

;   reset color for the 40-char line
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$14
                beq _processText

                lda DebugMsgColor,Y
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                inx
                sta CS_COLOR_MEM_PTR+v_RenderLine,X
                bra _nextColor

;   process the text
_processText

;   switch to text map
                lda #iopPage2
                sta IOPAGE_CTRL

                ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$14
                beq _XIT

                lda DebugMsg,Y
                beq _space
                cmp #$20
                beq _space

                cmp #$9B
                beq _bomb

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_bomb           sta CS_TEXT_MEM_PTR+v_RenderLine,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+v_RenderLine,X

                bra _nextChar

_XIT
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Reset the CPU IRQ vectors
;--------------------------------------
; prior to calling this:
;   ensure MMU slot 7 is configured
;   ensure SEI is active
;--------------------------------------
; preserve      A
;======================================
InitCPUVectors  .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei

                lda #<DefaultHandler
                sta vecABORT
                lda #>DefaultHandler
                sta vecABORT+1

                lda #<DefaultHandler
                sta vecNMI
                lda #>DefaultHandler
                sta vecNMI+1

                lda #<BOOT
                sta vecRESET
                lda #>BOOT
                sta vecRESET+1

                lda #<DefaultHandler
                sta vecIRQ_BRK
                lda #>DefaultHandler
                sta vecIRQ_BRK+1

                cli

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Default IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DefaultHandler  rti


;======================================
; Reset the MMU slots
;--------------------------------------
; prior to calling this:
;   ensure SEI is active
;--------------------------------------
; preserve      A
;               IOPAGE_CTRL
;               MMU_CTRL
;======================================
InitMMU         .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                lda #$00                ; [0000:1FFF]
                sta MMU_Block0
                inc A                   ; [2000:3FFF]
                sta MMU_Block1
                inc A                   ; [4000:5FFF]
                sta MMU_Block2
                inc A                   ; [6000:7FFF]
                sta MMU_Block3
                inc A                   ; [8000:9FFF]
                sta MMU_Block4
                inc A                   ; [A000:BFFF]
                sta MMU_Block5
                inc A                   ; [C000:DFFF]
                sta MMU_Block6
                inc A                   ; [E000:FFFF]
                sta MMU_Block7

;   restore MMU control
                pla
                sta MMU_CTRL

                cli

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
; Configure IRQ Handlers
;--------------------------------------
; prior to calling this:
;   ensure SEI is active
;--------------------------------------
; preserve      A
;======================================
InitIRQs        .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                sei                     ; disable IRQ

;   enable IRQ handler
                ;lda #<vecIRQ_BRK
                ;sta IRQ_PRIOR
                ;lda #>vecIRQ_BRK
                ;sta IRQ_PRIOR+1

                lda #<irqMain
                sta vecIRQ_BRK
                lda #>irqMain
                sta vecIRQ_BRK+1

;   initialize the console
                lda #$07
                sta CONSOL

;   initialize joystick/keyboard
                lda #$1F
                sta InputFlags
                ; sta InputFlags+1
                stz InputType           ; =joystick
                ; stz InputType+1

;   disable all IRQ
                lda #$FF
                sta INT_EDGE_REG0
                sta INT_EDGE_REG1
                sta INT_EDGE_REG2
                sta INT_MASK_REG0
                sta INT_MASK_REG1
                sta INT_MASK_REG2

;   clear pending interrupts
                lda INT_PENDING_REG0
                sta INT_PENDING_REG0
                lda INT_PENDING_REG1
                sta INT_PENDING_REG1
                lda INT_PENDING_REG2
                sta INT_PENDING_REG2

;   enable Start-of-Frame IRQ
                lda INT_MASK_REG0
                and #~INT00_SOF
                sta INT_MASK_REG0

;   enable Start-of-Line IRQ
                ;!!lda INT_MASK_REG0
                ;!!and #~INT00_SOL
                ;!!sta INT_MASK_REG0

;   enable Keyboard IRQ
                ;!! lda INT_MASK_REG1
                ;!! and #~INT01_VIA1
                ;!! sta INT_MASK_REG1

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                cli                     ; enable IRQ
                pla
                rts
                .endproc


;======================================
;
;--------------------------------------
; preserve      A, X, Y
;======================================
SetFont         .proc
                pha
                phx
                phy

;   DEBUG: helpful if you need to see the trace
                ; bra _XIT

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to charset map
                lda #iopPage1
                sta IOPAGE_CTRL

;   Font #0
FONT0           lda #<GameFont
                sta zpSource
                lda #>GameFont
                sta zpSource+1
                stz zpSource+2

                lda #<FONT_MEMORY_BANK0
                sta zpDest
                lda #>FONT_MEMORY_BANK0
                sta zpDest+1
                stz zpDest+2

                ldx #$08                ; 8 pages
_nextPage       ldy #$00
_next1          lda (zpSource),Y
                sta (zpDest),Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

_XIT            ply
                plx
                pla
                rts
                .endproc
