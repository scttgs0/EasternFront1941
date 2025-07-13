
;======================================
;
;--------------------------------------
; preserve      A, X, Y
;======================================
CheckCollision  .proc
                pha
                phx
                phy

                ldx #1                  ; Given: SP02_Y=112
_nextBomb       lda zpBombDrop,X        ; A=112
                beq _nextPlayer

                cmp #132
                bcs _withinRange
                bra _nextPlayer

_withinRange    sec
                sbc #132                ; A=8
                lsr             ; /2    ; A=4
                lsr             ; /4    ; A=2
                lsr             ; /8    ; A=1
                sta zpTemp1             ; zpTemp1=1 (row)

                lda PlayerPosX,X
                lsr             ; /4
                lsr
                sta zpTemp2             ; (column)

                lda #<CANYON
                sta zpSource
                lda #>CANYON
                sta zpSource+1

                ldy zpTemp1
_nextRow        beq _checkRock

                lda zpSource
                clc
                adc #40
                sta zpSource
                bcc _1

                inc zpSource+1

_1              dey
                bra _nextRow

_checkRock      ldy zpTemp2
                lda (zpSource),Y
                beq _nextPlayer

                cmp #4
                bcs _nextPlayer

                sta P2PF,X

                stz zpTemp1
                txa
                asl                     ; *2
                rol zpTemp1
                tay

                lda zpSource
                stz zpTemp2+1
                clc
                adc zpTemp2
                sta P2PFaddr,Y          ; low-byte

                lda zpSource+1
                adc #$00
                sta P2PFaddr+1,Y        ; high-byte

_nextPlayer     dex
                bpl _nextBomb

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Clear the bottom of the screen
;--------------------------------------
; preserve      A, Y
;======================================
; ClearGamePanel  .proc
; v_EmptyText     .var $00
; v_TextColor     .var $40
; v_RenderLine    .var 24*CharResX
; ;---

;                 pha
;                 phx
;                 phy

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   text color
;                 lda #<CS_COLOR_MEM_PTR+v_RenderLine
;                 sta zpDest
;                 lda #>CS_COLOR_MEM_PTR+v_RenderLine
;                 sta zpDest+1
;                 stz zpDest+2

;                 lda #v_TextColor
;                 ldy #$00
; _next1          sta (zpDest),Y

;                 iny
;                 cpy #$F0                ; 6 lines
;                 bne _next1

; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 lda #<CS_TEXT_MEM_PTR+v_RenderLine
;                 sta zpDest
;                 lda #>CS_TEXT_MEM_PTR+v_RenderLine
;                 sta zpDest+1
;                 stz zpDest+2

;                 lda #v_EmptyText
;                 ldy #$00
; _next2          sta (zpDest),Y

;                 iny
;                 cpy #$F0                ; 6 lines
;                 bne _next2

; ;   switch to system map
;                 stz IOPAGE_CTRL

;                 ply
;                 plx
;                 pla
;                 rts
;                 .endproc


;======================================
; Render High Score
;--------------------------------------
; preserve      A, X, Y
;======================================
; RenderHiScore   .proc
; v_RenderLine    .var 2*CharResX
; ;---

;                 pha
;                 phx
;                 phy

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   reset color for the 40-char line
;                 ldx #$FF
;                 ldy #$FF
; _nextColor      inx
;                 iny
;                 cpy #$14
;                 beq _processText

;                 lda HighScoreColor,Y
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 bra _nextColor

; ;   process the text
; _processText

; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 ldx #$FF
;                 ldy #$FF
; _nextChar       inx
;                 iny
;                 cpy #$14
;                 beq _XIT

;                 lda HighScoreMsg,Y
;                 beq _space
;                 cmp #$20
;                 beq _space

;                 cmp #$41
;                 bcc _number
;                 bra _letter

; _space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; ;   (ascii-30)*2+$A0
; _number         sec
;                 sbc #$30
;                 asl

;                 clc
;                 adc #$A0
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 inc A
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 clc
;                 adc #$40
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _XIT
; ;   switch to system map
;                 stz IOPAGE_CTRL

;                 ply
;                 plx
;                 pla
;                 rts
;                 .endproc


;======================================
; Render High Score
;--------------------------------------
; preserve      A, X, Y
;======================================
; RenderHiScore2  .proc
; v_RenderLine    .var 24*CharResX
; ;---

;                 pha
;                 phx
;                 phy

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   reset color for the 40-char line
;                 ldx #$FF
;                 ldy #$FF
; _nextColor      inx
;                 iny
;                 cpy #$14
;                 beq _processText

;                 lda HighScoreColor,Y
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 bra _nextColor

; ;   process the text
; _processText

; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 ldx #$FF
;                 ldy #$FF
; _nextChar       inx
;                 iny
;                 cpy #$14
;                 beq _XIT

;                 lda HighScoreMsg,Y
;                 beq _space
;                 cmp #$20
;                 beq _space

;                 cmp #$41
;                 bcc _number
;                 bra _letter

; _space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; ;   (ascii-30)*2+$A0
; _number         sec
;                 sbc #$30
;                 asl

;                 clc
;                 adc #$A0
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 inc A
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 clc
;                 adc #$40
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _XIT
; ;   switch to system map
;                 stz IOPAGE_CTRL

;                 ply
;                 plx
;                 pla
;                 rts
;                 .endproc


;======================================
; Render Title
;--------------------------------------
; preserve      A, X, Y
;======================================
; RenderTitle     .proc
; v_RenderLine    .var 24*CharResX
; ;---

;                 pha
;                 phx
;                 phy

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   reset color for two 40-char lines
;                 ldx #$FF
;                 ldy #$FF
; _nextColor      inx
;                 iny
;                 cpy #$50
;                 beq _processText

;                 lda TitleMsgColor,Y
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X

;                 bra _nextColor

; ;   process the text
; _processText
; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 ldx #$FF
;                 ldy #$FF
; _nextChar       inx
;                 iny
;                 cpy #$50
;                 beq _XIT

;                 lda TitleMsg,Y
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _XIT
; ;   switch to system map
;                 stz IOPAGE_CTRL

;                 ply
;                 plx
;                 pla
;                 rts
;                 .endproc


;======================================
; Render Author
;--------------------------------------
; preserve      A, X, Y
;======================================
; RenderAuthor    .proc
; v_RenderLine    .var 26*CharResX
; ;---

                pha
                phx
                phy

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   reset color for the 40-char line
;                 ldx #$FF
;                 ldy #$FF
; _nextColor      inx
;                 iny
;                 cpy #$14
;                 beq _processText

;                 lda AuthorColor,Y
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 bra _nextColor

; ;   process the text
; _processText

; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 ldx #$FF
;                 ldy #$FF
; _nextChar       inx
;                 iny
;                 cpy #$14
;                 beq _XIT

;                 lda AuthorMsg,Y
;                 beq _space
;                 cmp #$20
;                 beq _space

;                 bra _letter

; _space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 clc
;                 adc #$40
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _XIT
; ;   switch to system map
;                 stz IOPAGE_CTRL

                ply
                plx
                pla
;                 rts
;                 .endproc


;======================================
; Render SELECT (Qty of Players)
;--------------------------------------
; preserve      A, X, Y
;======================================
; RenderSelect    .proc
; v_RenderLine    .var 27*CharResX
; ;---

;                 pha
;                 phx
;                 phy

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   reset color for the 40-char line
;                 ldx #$FF
;                 ldy #$FF
; _nextColor      inx
;                 iny
;                 cpy #$14
;                 beq _processText

;                 lda PlyrQtyColor,Y
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 bra _nextColor

; ;   process the text
; _processText

; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 ldx #$FF
;                 ldy #$FF
; _nextChar       inx
;                 iny
;                 cpy #$14
;                 beq _XIT

;                 lda PlyrQtyMsg,Y
;                 beq _space
;                 cmp #$20
;                 beq _space

;                 cmp #$41
;                 bcc _number
;                 bra _letter

; _space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; ;   (ascii-30)*2+$A0
; _number         sec
;                 sbc #$30
;                 asl

;                 clc
;                 adc #$A0
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 inc A
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 clc
;                 adc #$40
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _XIT
; ;   switch to system map
;                 stz IOPAGE_CTRL

;                 ply
;                 plx
;                 pla
;                 rts
;                 .endproc


;======================================
; Render Title
;--------------------------------------
; preserve      A, X, Y
;======================================
; RenderPlayers   .proc
; v_RenderLine    .var 26*CharResX
; ;---

;                 pha
;                 phx
;                 phy

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   reset color for the 40-char line
;                 ldx #$FF
;                 ldy #$FF
; _nextColor      inx
;                 iny
;                 cpy #$14
;                 beq _processText

;                 lda PlayersMsgColor,Y
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 bra _nextColor

; ;   process the text
; _processText

; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 ldx #$FF
;                 ldy #$FF
; _nextChar       inx
;                 iny
;                 cpy #$14
;                 beq _XIT

;                 lda PlayersMsg,Y
;                 beq _space
;                 cmp #$20
;                 beq _space

;                 cmp #$41
;                 bcc _number
;                 bra _letter

; _space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; ;   (ascii-30)*2+$A0
; _number         sec
;                 sbc #$30
;                 asl

;                 clc
;                 adc #$A0
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 inc A
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 clc
;                 adc #$40
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _XIT
; ;   switch to system map
;                 stz IOPAGE_CTRL

;                 ply
;                 plx
;                 pla
;                 rts
;                 .endproc


;======================================
; Render Player Scores & Bombs
;--------------------------------------
; preserve      A, X, Y
;======================================
; RenderScore     .proc
; v_RenderLine    .var 27*CharResX
; ;---

;                 pha
;                 phx
;                 phy

; ;   if game is not in progress then exit
;                 lda zpWaitForPlay
;                 bne _XIT

; ;   switch to color map
;                 lda #iopPage3
;                 sta IOPAGE_CTRL

; ;   reset color for the 40-char line
;                 ldx #$FF
;                 ldy #$FF
; _nextColor      inx
;                 iny
;                 cpy #$14
;                 beq _processText

;                 lda ScoreMsgColor,Y
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_COLOR_MEM_PTR+v_RenderLine,X
;                 bra _nextColor

; ;   process the text
; _processText

; ;   switch to text map
;                 lda #iopPage2
;                 sta IOPAGE_CTRL

;                 ldx #$FF
;                 ldy #$FF
; _nextChar       inx
;                 iny
;                 cpy #$14
;                 beq _XIT

;                 lda ScoreMsg,Y
;                 beq _space
;                 cmp #$20
;                 beq _space

;                 cmp #$9B
;                 beq _bomb

;                 cmp #$41
;                 bcc _number
;                 bra _letter

; _space          sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; ;   (ascii-30)*2+$A0
; _number         sec
;                 sbc #$30
;                 asl

;                 clc
;                 adc #$A0
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 inc A
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _letter         sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 clc
;                 adc #$40
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _bomb           sta CS_TEXT_MEM_PTR+v_RenderLine,X
;                 inx
;                 inc A
;                 sta CS_TEXT_MEM_PTR+v_RenderLine,X

;                 bra _nextChar

; _XIT
; ;   switch to system map
;                 stz IOPAGE_CTRL

;                 ply
;                 plx
;                 pla
;                 rts
;                 .endproc



;======================================
; Initialize the Map layer
;======================================
InitMap         .proc
                pha

                ldx #0
                ldy #0
_nextTile       ;!!lda MAPWDW,Y            ; Get the tile code
                and #$7F
                ;!!sta TILEMAP,X           ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only

                lda #0
                ;!!sta TILEMAP,X
                inx                     ; move to the next tile

                iny
                ;!!cpy #MAPWIDTH*MAPHEIGHT
                bne _nextTile

                ;!!.m16
                ;!!lda #<>(TILEMAP-VRAM)   ; Set the pointer to the tile map
                ;!!sta TILE3_START_ADDR
                ;!!.m8
                ;!!lda #`(TILEMAP-VRAM)
                ;!!sta TILE3_START_ADDR+2

                ;!!.m16
                ;!!lda #MAPWIDTH                ; Set the size of the tile map
                ;!!sta TILE3_X_SIZE
                ;!!lda #MAPHEIGHT
                ;!!sta TILE3_Y_SIZE

                lda #$00
                ;!!sta TILE3_WINDOW_X_POS
                ;!!sta TILE3_WINDOW_Y_POS

                ;!!.m8
                lda #tcEnable           ; Enable the tileset, LUT0
                ;!!sta TILE3_CTRL

                pla
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;======================================
InitSprites     .proc
                pha

                ;!!.m16i16
                ;!!lda #$1800              ; Set the size
                sta SIZE
                lda #$00
                sta SIZE+2

                ;!!lda #<>PLYR0            ; Set the source address
                sta SOURCE
                ;!!lda #`PLYR0
                sta SOURCE+2

                ;!!lda #<>(SPRITES-VRAM)   ; Set the destination address
                sta DEST
                ;!!sta SP00_ADDR           ; And set the Vicky register
                clc
                ;!!adc #$400               ; 1024
                ;!!sta SP01_ADDR
                clc
                ;!!adc #$1000              ; 1024*4
                ;!!sta SP02_ADDR

                ;!!lda #`(SPRITES-VRAM)
                sta DEST+2

                ;!!.m8
                ;!!sta SP00_ADDR+2
                ;!!sta SP01_ADDR+2
                ;!!sta SP02_ADDR+2

                ;!!jsr Copy2VRAM

                ;!!.m16
                lda #$00
                ;!!sta SP00_X_POS
                ;!!sta SP00_Y_POS
                ;!!sta SP01_X_POS
                ;!!sta SP01_Y_POS
                ;!!sta SP02_X_POS
                ;!!sta SP02_Y_POS

                ;!!.m8
                lda #scEnable
                ;!!sta SP00_CTRL
                ;!!sta SP01_CTRL
                ;!!sta SP02_CTRL

                pla
                rts
                .endproc


;======================================
;
;======================================
RefreshUnitOverlay .proc
                ;!!.setbank `unitsData

                ;!!.m8i16
                ldx #0
                ldy #0
_nextTile       ;!!lda unitsData,Y         ; Get the tile code
                ;and #$7F
                ;!!sta TILEMAPUNITS,X      ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only
                lda #0
                ;!!sta TILEMAPUNITS,X

                inx                     ; move to the next tile
                iny
                ;!!cpy #MAPWIDTH*MAPHEIGHT
                bne _nextTile

                ;!!.setbank $03
                rts
                .endproc


;======================================
; Initialize the Unit layer (troops)
;======================================
InitUnitOverlay .proc
                jsr RefreshUnitOverlay

                ;!!lda #<(TILEMAPUNITS-VRAM)   ; Set the pointer to the tile map
                ;!!sta TILE2_ADDR
                ;!!lda #>(TILEMAPUNITS-VRAM)
                ;!!sta TILE2_ADDR+1
                ;!!lda #`(TILEMAPUNITS-VRAM)
                ;!!sta TILE2_ADDR+2

                ;!!lda #<MAPWIDTH           ; Set the size of the tile map
                sta TILE2_SIZE_X
                ;!!lda #>MAPWIDTH
                sta TILE2_SIZE_X+1
                ;!!lda #<MAPHEIGHT
                sta TILE2_SIZE_Y
                ;!!lda #>MAPHEIGHT
                sta TILE2_SIZE_Y+1

                stz TILE2_SCROLL_X
                stz TILE2_SCROLL_X+1
                stz TILE2_SCROLL_Y
                stz TILE2_SCROLL_Y+1

                lda #tcEnable           ; Enable the tileset, LUT0
                sta TILE2_CTRL

                rts
                .endproc
