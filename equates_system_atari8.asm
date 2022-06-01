;---------------------------------------
; System Equates for Atari
;---------------------------------------

RTCLOK          = $14                   ; jiffy clock
;ATRACT          = $4D
;DRKMSK          = $4E
;COLRSH          = $4F

;--------------------------------------

;   OS registers
SDMCTL          = $022F
SDLSTL          = $0230                 ; [word] Existing OS pointer to display list
GPRIOR          = $026F
STICK0          = $0278
PCOLR0          = $02C0
CH_             = $02FC

;--------------------------------------

;   GTIA registers
HPOSP0          = $D000
HPOSP1          = $D001
HPOSP2          = $D002
SIZEP0          = $D008
TRIG0           = $D010
TRIG1           = $D011
COLPF0          = $D016
COLPF1          = $D017
COLPF2          = $D018
COLBAK          = $D01A
GRACTL          = $D01D
CONSOL          = $D01F

;--------------------------------------

;   POKEY registers
AUDF1           = $D200
AUDC1           = $D201
;RANDOM          = $D20A

;--------------------------------------

;   ANTIC registers
HSCROL          = $D404
VSCROL          = $D405
PMBASE          = $D407
CHBASE          = $D409
WSYNC           = $D40A
NMIEN           = $D40E

;   ANTIC instructions
AJMP            = $0001
AVB             = $0040
AHSCR           = $0010
AVSCR           = $0020
ALMS            = $0040
ADLI            = $0080
AEMPTY0         = $0000
AEMPTY8         = $0070

;--------------------------------------

;   Vectors
SETVBV          = $E45C
XITVBV          = $E462
