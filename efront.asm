
; SPDX-PackageSummary: Eastern Front (1941)
; SPDX-PackageOriginator: Chris Crawford
; SPDX-PackageCopyrightText: 11/30/81 Copyright Chris Crawford 1981
; SPDX-FileName: efront.asm


;   MEMORY MAP:
;   -----------
;   00      direct-page, interrupt proxy
;                   0800-08cd           direct-page
;   02      code
;                   0fd8-0ffb           PGX bootstrap
;                   1000-17a2           thinking (AI)
;                   2000-280f           main
;                   3000-3509           combat
;                   4000-48d5           interrupt
;                   5000-527b           platform_c256
;   03      data
;                   0000-127c           data
;   04      palette, font, text, map
;                   0000-01fb           PALETTE
;                   1000-afff           FONT
;                   b000-d9aa           TEXT
;                   e000-e865           MAP
;                   f000-f865           units
;   05      tiles, sprites
;                   0000-82ff           TILES
;                   9000-abff           STAMPS
;   06-0A   bitmaps
;                   06:0000-4fff        header
;                   06:5000-09:e7ff     <empty>
;                   09:e800-0a:afff     footer


                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_sprite.mac"
                .include "macros/game.mac"


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

.if PGZ=0
                .byte $F2,$56               ; signature
                .byte $02                   ; block count
                .byte $01                   ; start at block1
                .addr BOOT_                 ; execute address
                .word $0001                 ; version
                .word $0000                 ; kernel
                .null 'Eastern Front 1941'  ; binary name
.endif


;--------------------------------------
;--------------------------------------
                ; * = INIT-40
;--------------------------------------
                ; .text "PGX"
                ; .byte $01
                ; .dword BOOT_

BOOT_           cld

                ldx #$FF
                txs

                stz IOPAGE_CTRL

                stz BACKGROUND_COLOR_R
                stz BACKGROUND_COLOR_G
                stz BACKGROUND_COLOR_B

                jmp START


;--------------------------------------
;--------------------------------------
                ; * = $02_1000
;--------------------------------------

                .include "thinking.asm"
                .include "main.asm"
                .include "combat.asm"
                .include "interrupt.asm"
                .include "platform_f256.asm"
                .include "facade.asm"


;--------------------------------------
;--------------------------------------
                .align $0100
;--------------------------------------
                .include "data/DATA.inc"


;--------------------------------------
;--------------------------------------
                .align $0400
;--------------------------------------
palette         .include "data/PALETTE.inc"
palette_end

                .align $0100
font            .include "data/FONT.inc"

                ;!!.align $1000
textData        .include "TEXT.asm"

                .align $01_0000
mapData         .include "data/MAP.inc"

                .align $0100
unitsData       .fill MAPWIDTH*MAPHEIGHT,$00


;--------------------------------------
                * = $05_0000
;--------------------------------------

tiles           .include "data/TILES.inc"

                .align $1000
stamps          .include "data/STAMPS.inc"


;--------------------------------------
;--------------------------------------
                ;!!.align $10000
;--------------------------------------
HeaderPanel     ;!!.binary "images/header.raw"
                ;!!.fill $39800,$00
FooterPanel     ;!!.binary "images/footer.raw"
