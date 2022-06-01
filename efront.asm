;==================================================================
;==================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

                .cpu "65816"

                .include "equates_system_atari8.asm"
                .include "equates_system_c256.asm"
                .include "equates_directpage.asm"
                .include "equates_page6.asm"
                .include "macros_65816.asm"

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
                .setdp $0060
                .setbank $00
                jml START

;--------------------------------------

                .include "thinking.asm"
                .include "combat.asm"
                .include "data.asm"
                .include "main.asm"
                .include "interrupt.asm"
