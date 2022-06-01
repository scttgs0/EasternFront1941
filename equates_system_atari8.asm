;---------------------------------------
; System Equates for Atari
;---------------------------------------

RTCLOK          = $14                   ; jiffy clock
;DRKMSK          = $4E
;COLRSH          = $4F

;--------------------------------------

;   OS registers
SDLSTL          = $0230                 ; [word] Existing OS pointer to display list

;--------------------------------------

;   GTIA registers
HPOSP0          = $D000
HPOSP1          = $D001
HPOSP2          = $D002
;GRACTL          = $D01D

;--------------------------------------

;   POKEY registers
AUDF1           = $D200
AUDC1           = $D201

;--------------------------------------

;   ANTIC registers
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
