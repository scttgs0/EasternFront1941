;==================================================================
;==================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

                .cpu "65816"

                .include "equates_system_c256.asm"
                .include "equates_directpage.asm"
                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"

                .enc "atari-screen"
                .cdef " Z", $00
                .enc "none"

;======================================
;======================================
                * = INIT-40
;======================================
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0800
                .setbank $02

                jml START

;--------------------------------------

                .include "thinking.asm"
                .include "combat.asm"
                .include "data.asm"
                .include "main.asm"
                .include "interrupt.asm"
                .include "platform_c256.asm"

;--------------------------------------
;--------------------------------------

palette         .include "pal.asm"
palette_end

                * = $03_0000
tiles           .include "TILESB.asm"
