;======================================
; Direct-page variables
;======================================

;--------------------------------------
;--------------------------------------
                * = $B0
;--------------------------------------

;   These locations are used by the interrupt service routine
DLSTPT          .word ?         ; [$B0]  Zero page pointer to display list
MAPLO           .byte ?
MAPHI           .byte ?
CORPS           .byte ?                 ; number of unit under window
CURSXL          .byte ?
CURSXH          .byte ?
CURSYL          .byte ?                 ; cursor coordinates on screen (map frame)
CURSYH          .byte ?         ; [$B8]
OFFLO           .byte ?                 ; How far to offset new LMS value
OFFHI           .byte ?
TEMPI           .byte ?                 ; An all-purpose temporary register
CNT1            .byte ?                 ; DLI counter
CNT2            .byte ?                 ; DLI counter for movable map DLI
CHUNKX          .byte ?                 ; cursor coordinates (pixel frame)
CHUNKY          .byte ?         ; [$BF]


;   These locations are for the mainline routines
MAPPTR          .word ?         ; [$C0]
ARMY            .byte ?
UNITNO          .byte ?
DEFNDR          .byte ?
TEMPR           .byte ?
TEMPZ           .byte ?
ACCLO           .byte ?
ACCHI           .byte ?         ; [$C8]
TURN            .byte ?
LAT             .byte ?
LONG            .byte ?
RFR             .byte ?
TRNTYP          .byte ?
SQVAL           .byte ?         ; [$CE]
