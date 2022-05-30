;---------------------------------------
; System Equates for Atari
;---------------------------------------

RTCLOK          = $14
ATRACT          = $4D
DRKMSK          = $4E
COLRSH          = $4F

SDMCTL          = $022F
SDLSTL          = $0230                 ; [word] Existing OS pointer to display list
GPRIOR          = $026F
STICK0          = $0278
PCOLR0          = $02C0
CH_             = $02FC

HPOSP0          = $D000
HPOSP1          = $D001
HPOSP2          = $D002
HPOSP3          = $D003
SIZEP0          = $D008
TRIG0           = $D010
TRIG1           = $D011
TRIG2           = $D012
COLPF0          = $D016
COLPF1          = $D017
COLPF2          = $D018
COLBAK          = $D01A
GRACTL          = $D01D
CONSOL          = $D01F

AUDF1           = $D200
AUDC1           = $D201
RANDOM          = $D20A

HSCROL          = $D404
VSCROL          = $D405
PMBASE          = $D407
CHBASE          = $D409
WSYNC           = $D40A
NMIEN           = $D40E

SETVBV          = $E45C
XITVBV          = $E462
