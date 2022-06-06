VRAM            = $B00000               ; First byte of video RAM

TILESET         = VRAM
TILEMAP         = $B20000
TILEMAPUNITS    = $B22000
SPRITES         = $B24000
BITMAP          = $B30000


;======================================
; Create the lookup table (LUT)
;======================================
InitLUT         .proc
                phb
                php

                .m16i16
                lda #palette_end-palette ; Copy the palette to LUT0
                ldx #<>palette
                ldy #<>GRPH_LUT0_PTR
                mvn `palette,`GRPH_LUT0_PTR

                plp
                plb
                rts
                .endproc


;======================================
; Load the tiles into VRAM
;======================================
InitTiles       .proc
                phb
                php

                .m16i16
                lda #$FFFF              ; Set the size
                sta SIZE
                lda #$00
                sta SIZE+2

                lda #<>tiles            ; Set the source address
                sta SOURCE
                lda #`tiles
                sta SOURCE+2

                lda #<>(TILESET-VRAM)   ; Set the destination address
                sta DEST
                sta TILESET0_ADDR       ; And set the Vicky register
                lda #`(TILESET-VRAM)
                sta DEST+2
                .m8
                sta TILESET0_ADDR+2

                jsr Copy2VRAM

                ; set tileset layout to linear-vertical (16x4096)
                .m8
                lda #tclVertical
                sta TILESET0_ADDR_CFG

                plp
                plb
                rts
                .endproc


;======================================
; Initialize the Map layer
;======================================
InitMap         .proc
                phb
                php

                .setbank `MAPWDW

                .m8i16
                ldx #0
                ldy #0
_nextTile       lda MAPWDW,Y            ; Get the tile code
                and #$7F
                sta TILEMAP,X           ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only
                lda #0
                sta TILEMAP,X

                inx                     ; move to the next tile
                iny
                cpy #$810               ; 48x43
                bne _nextTile

                .m16
                lda #<>(TILEMAP-VRAM)   ; Set the pointer to the tile map
                sta TILE3_START_ADDR
                .m8
                lda #`(TILEMAP-VRAM)
                sta TILE3_START_ADDR+2

                .m16
                lda #48                ; Set the size of the tile map
                sta TILE3_X_SIZE
                lda #43
                sta TILE3_Y_SIZE

                lda #$00
                sta TILE3_WINDOW_X_POS
                sta TILE3_WINDOW_Y_POS

                .m8
                lda #tcEnable           ; Enable the tileset, LUT0
                sta TILE3_CTRL

                plp
                plb
                rts
                .endproc


;======================================
; Initialize the Unit layer (troops)
;======================================
InitUnitOverlay .proc
                phb
                php

                .setbank `unitsData

                .m8i16
                ldx #0
                ldy #0
_nextTile       lda unitsData,Y         ; Get the tile code
                ;and #$7F
                sta TILEMAPUNITS,X      ; save it to the tile map
                inx                     ; Note: writes to video RAM need to be 8-bit only
                lda #0
                sta TILEMAPUNITS,X

                inx                     ; move to the next tile
                iny
                cpy #$810               ; 48x43
                bne _nextTile

                .m16
                lda #<>(TILEMAPUNITS-VRAM)   ; Set the pointer to the tile map
                sta TILE2_START_ADDR
                .m8
                lda #`(TILEMAPUNITS-VRAM)
                sta TILE2_START_ADDR+2

                .m16
                lda #48                ; Set the size of the tile map
                sta TILE2_X_SIZE
                lda #43
                sta TILE2_Y_SIZE

                lda #$00
                sta TILE2_WINDOW_X_POS
                sta TILE2_WINDOW_Y_POS

                .m8
                lda #tcEnable           ; Enable the tileset, LUT0
                sta TILE2_CTRL

                plp
                plb
                rts
                .endproc


;======================================
; Initialize the Sprite layer
;======================================
InitSprites     .proc
                phb
                php

                .m16i16
                lda #$1C00              ; Set the size
                sta SIZE
                lda #$00
                sta SIZE+2

                lda #<>PLYR0            ; Set the source address
                sta SOURCE
                lda #`PLYR0
                sta SOURCE+2

                lda #<>(SPRITES-VRAM)   ; Set the destination address
                sta DEST
                sta SP00_ADDR           ; And set the Vicky register
                clc
                adc #1024
                sta SP01_ADDR
                clc
                adc 1024*4
                sta SP02_ADDR

                lda #`(SPRITES-VRAM)
                sta DEST+2

                .m8
                sta SP00_ADDR+2
                sta SP01_ADDR+2
                sta SP02_ADDR+2

                jsr Copy2VRAM

                .m16
                lda #$00
                sta SP00_X_POS
                sta SP00_Y_POS
                sta SP01_X_POS
                sta SP01_Y_POS
                sta SP02_X_POS
                sta SP02_Y_POS

                .m8
                lda #scEnable
                sta SP00_CTRL
                sta SP01_CTRL
                sta SP02_CTRL

                plp
                plb
                rts
                .endproc


InitBitmap      .proc
                phb
                php

                .m16i16
                lda #$B000              ; Set the size
                sta SIZE
                lda #$04
                sta SIZE+2

                lda #<>HeaderPanel      ; Set the source address
                sta SOURCE
                lda #`HeaderPanel
                sta SOURCE+2

                lda #<>(BITMAP-VRAM)   ; Set the destination address
                sta DEST
                sta BITMAP0_START_ADDR ; And set the Vicky register

                lda #`(BITMAP-VRAM)
                sta DEST+2

                .m8
                sta BITMAP0_START_ADDR+2

                jsr Copy2VRAM

                lda #bmcEnable
                sta BITMAP0_CTRL

                plp
                plb
                rts
                .endproc


;======================================
; Copying data from system RAM to VRAM
;--------------------------------------
; Inputs (pushed to stack, listed top down)
;   SOURCE = address of source data (should be system RAM)
;   DEST = address of destination (should be in video RAM)
;   SIZE = number of bytes to transfer
;
; Outputs:
;   None
;======================================
Copy2VRAM       .proc
                phd
                php

                .setdp SOURCE
                .setbank `SDMA_SRC_ADDR
                .m8

    ; Set SDMA to go from system to video RAM, 1D copy
                lda #sdcSysRAM_Src|sdcEnable
                sta SDMA0_CTRL

    ; Set VDMA to go from system to video RAM, 1D copy
                lda #vdcSysRAM_Src|vdcEnable
                sta VDMA_CTRL

                .m16i8
                lda SOURCE              ; Set the source address
                sta SDMA_SRC_ADDR
                ldx SOURCE+2
                stx SDMA_SRC_ADDR+2

                lda DEST                ; Set the destination address
                sta VDMA_DST_ADDR
                ldx DEST+2
                stx VDMA_DST_ADDR+2

                .m16
                lda SIZE                ; Set the size of the block
                sta SDMA_SIZE
                sta VDMA_SIZE
                lda SIZE+2
                sta SDMA_SIZE+2
                sta VDMA_SIZE+2

                .m8
                lda VDMA_CTRL           ; Start the VDMA
                ora #vdcStart_TRF
                sta VDMA_CTRL

                lda SDMA0_CTRL          ; Start the SDMA
                ora #sdcStart_TRF
                sta SDMA0_CTRL

                nop                     ; VDMA involving system RAM will stop the processor
                nop                     ; These NOPs give Vicky time to initiate the transfer and pause the processor
                nop                     ; Note: even interrupt handling will be stopped during the DMA
                nop

wait_vdma       lda VDMA_STATUS         ; Get the VDMA status
                bit #vdsSize_Err|vdsDst_Add_Err|vdsSrc_Add_Err
                bne vdma_err            ; Go to monitor if there is a VDMA error
                bit #vdsVDMA_IPS        ; Is it still in process?
                bne wait_vdma           ; Yes: keep waiting

                lda #0                  ; Make sure DMA registers are cleared
                sta SDMA0_CTRL
                sta VDMA_CTRL

                plp
                pld
                rts

vdma_err        brk
                .endproc
