;==================================================================
;==================================================================
; Eastern Front (1941)
; 11/30/81 COPYRIGHT CHRIS CRAWFORD 1981
;==================================================================

                .cpu "65816"

                .include "equates_system_atari8.asm"
                .include "equates_directpage.asm"
                .include "equates_page6.asm"

                .enc "atari-screen"
                .cdef " Z", $00
                .enc "none"

;======================================
;======================================
                * = INIT-16
;======================================
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            jml START

;--------------------------------------

                .include "EFT18Thinking.asm"
                .include "EFT18Combat.asm"
                .include "EFT18Data.asm"
                .include "EFT18Mainline.asm"
                .include "EFT18Interrupt.asm"
