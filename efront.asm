;==================================================================
;==================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================


;   MEMORY MAP:
;   -----------
;   00      direct-page, interrupt proxy
;                   0800-08cd           direct-page
;   02      code
;                   0fd8-0ffb           PGX bootstrap
;                   1000-17a9           thinking (AI)
;                   2000-2896           main
;                   3000-3509           combat
;                   4000-4711           interrupt
;                   5000-50a3               DLISRV
;                   6000-625b           platform_c256
;   03      data
;                   0000-1280           data
;   04      palette, font, text, map
;                   0000-01fb           PALETTE
;                   1000-afff           FONT
;                   b000-d948           TEXT
;                   e000-e80f           MAP
;                   f000-f80f           units
;   05      tiles, sprites
;                   0000-82ff           TILES
;                   9000-abff           STAMPS
;   06-0A   bitmaps
;                   06:0000-4fff        header
;                   06:5000-09:e7ff     <empty>
;                   09:e800-0a:afff     footer


                .cpu "65816"

                .include "equates_system_c256.asm"
                .include "equates_directpage.asm"
                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"

;--------------------------------------
;--------------------------------------
                * = INIT-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0800
                .setbank $03

                jml START

;--------------------------------------
;--------------------------------------
                * = $02_1000
;--------------------------------------

                .include "thinking.asm"

                .align $1000
                .include "main.asm"

                .align $1000
                .include "combat.asm"

                .align $1000
                .include "interrupt.asm"

                .align $1000
                .include "platform_c256.asm"

;--------------------------------------
;--------------------------------------
                * = $03_0000
;--------------------------------------
                .include "data.asm"


;--------------------------------------
;--------------------------------------
                * = $04_0000
;--------------------------------------
palette         .include "PALETTE.asm"
palette_end

                .align $1000
font            .include "FONT.asm"

                .align $1000
textData        .include "TEXT.asm"

                .align $1000
mapData         .include "MAP.asm"

                .align $1000
unitsData       .fill $810,$00

;--------------------------------------
;--------------------------------------
                .align $10000
;--------------------------------------
tiles           .include "TILES.asm"

                .align $1000
stamps          .include "STAMPS.asm"


;--------------------------------------
;--------------------------------------
                .align $10000
;--------------------------------------
HeaderPanel     .binary "images/header.raw"
                .fill $39800,$00
FooterPanel     .binary "images/footer.raw"
